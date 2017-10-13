var express = require('express');
var morgan = require('morgan');
var bodyParser = require('body-parser');

var Login = require('./models/login');
var Users = require('./models/users');

var app = express();

var port = process.env.PORT || 8080;

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

module.exports = app;
