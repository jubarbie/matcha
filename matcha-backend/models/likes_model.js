var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getNumberOfLikes = function(id, cb) {
	connection.query('SELECT * FROM likes WHERE id_to="' + id + '"', cb);
};

model.newLike = function(id_from, id_to, cb) {
	connection.query('INSERT INTO likes (id_from, id_to) VALUES ("'+id_from+'","'+id_to+'")', cb);
};

model.removeLike = function(id, id_user) {
	connection.query('DELETE FROM likes WHERE id="'+id+'")', cb);
};

model.getLikeFromUsers = function(id_from, id_to, cb) {
	connection.query('SELECT * FROM likes WHERE id_from="' + id_from + '" AND id_to="' + id_to + '"', cb);
};

module.exports = model;
