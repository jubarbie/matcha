var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getAllUsers = function(cb) {
	connection.query('SELECT * FROM user', cb);
}

model.getUserWithLogin = function(login, cb) {
	connection.query('SELECT * FROM user WHERE login="' + login + '"', cb);
}

model.insertUser = function(user, cb) {
	connection.query('INSERT INTO user (login, email, fname, lname, password, gender, interested_in, bio) VALUES ("'+user.login+'","'+user.email+'","'+user.fname+'", "'+user.lname+'","'+user.password+'","'+user.gender+'","'+user.int_in+'","'+user.bio+'")', cb);
}

module.exports = model;
