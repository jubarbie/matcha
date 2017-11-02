var express = require('express');
var morgan = require('morgan');
var bodyParser = require('body-parser');

var Login = require('./controllers/login');
var Users = require('./controllers/users');
var Talks = require('./controllers/talks');

var app = express();
var expressWs = require('express-ws')(app);

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
app.use('/api/users', Users);
app.use('/api/talks', Talks);

app.ws('/talking', function(ws, req) {
  ws.on('message', function(msg) {
    console.log(msg);
		ws.send('test');
  });
  console.log('socket', req.testing);
});

module.exports = app;
