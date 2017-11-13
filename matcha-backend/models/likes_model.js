var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getNumberOfLikes = function(username, cb) {
	connection.query('SELECT COUNT(*) FROM likes WHERE user_to = ?', [username], cb);
};

model.like = function(user_from, user_to, cb) {
	connection.query('INSERT INTO likes (user_from, user_to) VALUES ( ?, ?)', [user_from, user_to], cb);
};

model.unLike = function(user_from, user_to, cb) {
	connection.query('DELETE FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);
};

model.getLikeBetweenUsers = function(user_from, user_to, cb) {
	connection.query('SELECT * FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);
};

module.exports = model;
