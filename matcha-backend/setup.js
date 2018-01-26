var mysql = require('mysql');
var config = require('./config');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var jwt = require('jsonwebtoken');
var UsersModel = require('./models/users_model');

var db = config.database;
var connection = mysql.createConnection({
	host     : db.host,
	port     : db.port,
	user     : db.user,
	password : db.password,
	insecureAuth : true,
	multipleStatements : true,
});

var fs = require('fs');
var dataset = fs.readFileSync('./database.sql', "utf8");
var create_database = 'DROP DATABASE IF EXISTS matcha_db ;';
create_database += 'CREATE DATABASE matcha_db ; USE matcha_db;';
create_database += dataset;

connection.query(create_database, function(err, rows, fields) {
	connection.end();
	if (!err) {
	    console.log('Database created');
	} else {
	    console.log('Error while creating database', err);
	}
});
