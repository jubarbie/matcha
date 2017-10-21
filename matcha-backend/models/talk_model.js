var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getTalkFromUsers = function(id1, id2, cb) {
	connection.query('SELECT * FROM talk WHERE id_user1="' + id1 + '" AND id_user2="' + id2 + '"', cb);
};

model.newTalk = function(id1, id2, cb) {
	connection.query('INSERT INTO talk (id_user1, id_user2) VALUES ("'+id1+'","'+id2+'")', cb);
};

model.newMessage = function(id_talk, message, id_user) {
	connection.query('INSERT INTO message (id_user, message, id_talk) VALUES ("'+id_user+'","'+message+'","'+id_talk+'")', cb);
};

model.getUserTalks = function(id, cb) {
	connection.query('SELECT * FROM talk WHERE id"' + id + '"', cb);
};

model.getTalkMessages = function(id, cb) {
	connection.query('SELECT * FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.id="' + id + '" ORDER BY message.date ASC LIMIT 10', cb);
};

module.exports = model;
