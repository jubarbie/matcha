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
const app = express();
const expressWs = require('express-ws')(app);
const config = require('./config');
const jwt = require('jsonwebtoken');
const UsersModel = require('./models/users_model');
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
    res.header("Access-Control-Allow-Origin", "http://localhost:3000");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
});

app.get('/', function(req, res) {
    res.send('Hello! The API is at http://localhost:' + port + '/api');
});

app.use('/auth', Login);
app.post('/api/*', Auth.hasRole(1));
app.use('/api/users', Users);
app.use('/api/tag', Tag);
app.use('/api/talks', Talks);

var aWss = expressWs.getWss('/');
app.ws('/ws', function(ws, req) {

    ws.on('message', function(msg) {
        var data = JSON.parse(msg);
        try {
            var decoded = jwt.verify(data.jwt, config.secret);
            switch (data.action) {
                case "new_message":
                    Ctrl_talks.new_message(decoded.username, data.to, data.message);
                    aWss.clients.forEach(function each(client) {
                        client.send(JSON.stringify({
                            message: 'message',
                            to: data.to,
                            from: decoded.username,
                            notif: 0
                        }));
                    });
                    break;
                case "like":
                    LikesModel.getNotifLike(data.to, (err, rows, fields) => {
                      if (rows.length > 0) {
                        aWss.clients.forEach(function each(client) {
                            client.send(JSON.stringify({
                                message: 'like',
                                to: data.to,
                                from: decoded.username,
                                notif: rows[0].notif
                            }));
                        });
                      }
                    });
                    break;
                  case "visit":
                      VisitsModel.getNotifVisit(data.to, (err, rows, fields) => {
                        if (rows.length > 0) {
                          console.log(rows);
                          aWss.clients.forEach(function each(client) {
                              client.send(JSON.stringify({
                                  message: 'visit',
                                  to: data.to,
                                  from: decoded.username,
                                  notif: rows[0].notif
                              }));
                          });
                        }
                      });
                      break;
                default:
                    aWss.clients.forEach(function each(client) {
                        client.send('somethign!');
                    });
            }
        } catch (err) {
            console.log(err)
        }

    });
});

module.exports = app;
