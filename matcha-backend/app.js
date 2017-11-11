var express = require('express');
var morgan = require('morgan');
var bodyParser = require('body-parser');

var Auth = require('./middlewares/authentification');
var Login = require('./routes/login');
var Users = require('./routes/users');
var Talks = require('./routes/talks');
var Admin = require('./routes/admin');

var app = express();
var expressWs = require('express-ws')(app);

var config = require('./config');
var jwt = require('jsonwebtoken');
var UsersModel = require('./models/users_model');

app.use(morgan('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

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
app.use('/api/talks', Talks);
app.post('/api/admin/*', Auth.hasRole(0));
app.use('/api/admin', Admin);

app.ws('/talking', function(ws, req) {
  ws.on('message', function(msg) {
    console.log(msg);
		ws.send('test');
  });
  console.log('socket', req.testing);
});

module.exports = app;
