const express = require('express');
const morgan = require('morgan');
const bodyParser = require('body-parser');
const url = require('url');
const Auth = require('./middlewares/authentification');
const Login = require('./routes/login');
const Users = require('./routes/users');
const Talks = require('./routes/talks');
const Tag = require('./routes/tag');
const Ctrl_talks = require('./controllers/talk_ctrl');
const Ctrl_users = require('./controllers/user_ctrl');
const app = express();
const expressWs = require('express-ws')(app);
const config = require('./config');
const jwt = require('jsonwebtoken');
const UsersModel = require('./models/users_model');
const TalksModel = require('./models/talk_model');
const LikesModel = require('./models/likes_model');
const VisitsModel = require('./models/visits_model');


app.use(express.static('public'));

app.use(morgan('dev'));
app.use(bodyParser.json({
    limit: '50mb'
}));
app.use(bodyParser.urlencoded({
    extended: true,
    limit: '50mb'
}));

app.use(function(req, res, next) {
  // Disable caching for content files
    res.header("Cache-Control", "no-cache, no-store, must-revalidate");
    res.header("Pragma", "no-cache");
    res.header("Expires", 0);
    res.header("Access-Control-Allow-Origin", "http://localhost:3000");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, Authorization");
    next();
});

app.get('/', function(req, res) {
    res.send('js/matcha.js');
});

app.use('/auth', Login);
app.get('/api/*', Auth.hasRole(1));
app.post('/api/*', Auth.hasRole(1));
app.use('/api/users', Users);
app.use('/api/tag', Tag);
app.use('/api/talks', Talks);

var aWss = expressWs.getWss('/');
var clients = [];
aWss.on('connection', function(ws) {
  clients.push(ws);
  //console.log('connection', ws);
});
app.ws('/ws', function(ws, req) {
    ws.on('message', function(msg) {
        var data = JSON.parse(msg);
        var now = Date.now();
        try {
            var decoded = jwt.verify(data.jwt, config.secret);
            UsersModel.getUserWithUuid(decoded.id, function(err, rows, fields) {
                if (!err && rows.length > 0) {
                    let logged_user = rows[0];

                    switch (data.action) {
                        case "new_message":
                            var usersTab = [logged_user.login, data.to].sort();
                            var userNb = "user" + (usersTab.indexOf(logged_user.login) + 1) + "_last";
                            Ctrl_users.is_blocked(logged_user.login, data.to, (resp) => {
                              if (!resp) {
                                Ctrl_talks.new_message(logged_user.login, data.to, data.message);
                                TalksModel.getTalkNotif(usersTab, userNb, (err, rows, fields) => {
                                  if (!err && rows.length > 0) {
                                    aWss.clients.forEach(function each(client) {
                                        client.send(JSON.stringify({
                                            message: 'message',
                                            to: data.to,
                                            from: logged_user.login,
                                            notif: rows.map(row => row.user_from)
                                        }));
                                      });
                                    }
                                   else {
                                     //console.log(err);
                                   }
                                  });
                              } else {

                            }
                          });
                          break;
                        case "like":
                            LikesModel.getNotifLike(data.to, (err, rows, fields) => {
                              if (rows.length > 0) {
                                aWss.clients.forEach(function each(client) {
                                    client.send(JSON.stringify({
                                        message: 'like',
                                        to: data.to,
                                        from: logged_user.login,
                                        notif: rows.map(row => row.user_from)
                                    }));
                                });
                              }
                            });
                            break;
                        case "unlike":
                              LikesModel.getNotifUnLike(data.to, (err, rows, fields) => {
                                if (rows.length > 0) {
                                  aWss.clients.forEach(function each(client) {
                                      client.send(JSON.stringify({
                                          message: 'unlike',
                                          to: data.to,
                                          from: logged_user.login,
                                          notif: rows.map(row => row.user_from)
                                      }));
                                  });
                                }
                              });
                              break;
                          case "visit":
                              VisitsModel.addVisit(logged_user.login, data.to, now, (err1, rows1, fields) => {
                                VisitsModel.getNotifVisit(data.to, (err2, rows2, fields) => {
                                  if (rows2.length > 0) {
                                    aWss.clients.forEach(function each(client) {
                                        client.send(JSON.stringify({
                                            message: 'visit',
                                            to: data.to,
                                            from: logged_user.login,
                                            notif: rows2.map(row => row.user_from)
                                        }));
                                    });
                                  }
                                });
                              });
                              break;
                        default:
                            aWss.clients.forEach(function each(client) {
                                client.send('somethign!');
                            });
                    }
                  } else {
                    console.log('Unauthorized user');
                  }
                  });
        } catch (err) {
            console.log(err)
        }

    });
});

module.exports = app;
