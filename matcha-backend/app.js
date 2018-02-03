var express = require('express');
var morgan = require('morgan');
var bodyParser = require('body-parser');
var url = require('url');

var Auth = require('./middlewares/authentification');
var Login = require('./routes/login');
var Users = require('./routes/users');
var Talks = require('./routes/talks');
var Tag = require('./routes/tag');
var Admin = require('./routes/admin');

var Ctrl_talks = require('./controllers/talk_ctrl');

var app = express();
var expressWs = require('express-ws')(app);

var config = require('./config');
var jwt = require('jsonwebtoken');
var UsersModel = require('./models/users_model');


app.use(express.static('public'));

app.use(morgan('dev'));
app.use(bodyParser.json({limit: '50mb'}));
app.use(bodyParser.urlencoded({ extended: true, limit: '50mb' }));

app.use(function(req, res, next) {
	res.header("Access-Control-Allow-Origin", "http://localhost:3000");
	res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
	next();
});

app.get('/', function(req, res) {
	res.send('Hello! The API is at http://localhost:'+port+'/api');
});

app.use('/auth', Login);
app.post('/api/*', Auth.hasRole(1));
app.use('/api/users', Users);
app.use('/api/tag', Tag);
app.use('/api/talks', Talks);
app.post('/api/admin/*', Auth.hasRole(0));
app.use('/api/admin', Admin);

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
		       client.send(JSON.stringify({message: 'message', to: data.to, from: decoded.username}));
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
