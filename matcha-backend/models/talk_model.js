var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getTalkFromUsers = function(username1, username2, cb) {
	connection.query('SELECT * FROM talk WHERE username1="' + username1 + '" AND username2="' + username2 + '"', cb);
};

model.newTalk = function(username1, username2, cb) {
	connection.query('INSERT INTO talk (username1, username2) VALUES ("'+username1+'","'+username2+'")', cb);
};

model.newMessage = function(id_talk, message, username, date, cb) {
	connection.query('INSERT INTO message (username, message, id_talk, date) VALUES ("'+username+'","'+message+'","'+id_talk+'","'+date+'")', cb);
};

model.getUserTalks = function(username, cb) {
	connection.query('SELECT * FROM talk WHERE username1="' + username + '" OR username2="'+username+'"', cb);
};

model.getTalkMessages = function(id, cb) {
	connection.query('SELECT * FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.id="' + id + '" ORDER BY message.date DESC LIMIT 50', cb);
};

module.exports = model;
