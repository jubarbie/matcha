var mysql = require('mysql');
var config = require('./config');

var db = config.database;
var connection = mysql.createConnection({
	host     : db.host,
	port     : db.port,
	user     : db.user,
	password : db.password,
	multipleStatements : true,
	//socketPath: '/tmp/mysql.sock'
});

var fs = require('fs');
var dataset = fs.readFileSync('./dataset.sql', "utf8");
var create_database = 'DROP DATABASE IF EXISTS matcha_db ;';
create_database += 'CREATE DATABASE matcha_db ;';
create_database += 'CREATE TABLE matcha_db.user (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, login VARCHAR(255), password TEXT, fname VARCHAR(255) NOT NULL, lname VARCHAR(255) NOT NULL, email VARCHAR(255), gender VARCHAR(1),  interested_in VARCHAR(15), bio TEXT ) ;';
create_database += dataset;
connection.query(create_database, function(err, rows, fields) {
	connection.end();
	if (!err)
	    console.log('Database matcha_db created', rows);
	else
	    console.log('Error while creating database', err);
});

module.exports = mysql;

