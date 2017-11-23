var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.searchTags = (search, cb) => {
	connection.query('SELECT DISTINCT tag FROM rel_user_tag WHERE tag LIKE ? LIMIT 10', [search], cb);
};

model.addTag = (login, tag, cb) => {
	connection.query(' \
		INSERT INTO rel_user_tag (login , tag) \
		SELECT ?, ? \
 		WHERE NOT EXISTS (SELECT login, tag FROM rel_user_tag \
									 WHERE login = ? AND tag = ?) \
		', [ login, tag, login, tag  ], cb);
};

model.getTagsFromLogin = (login, cb) => {
	connection.query('SELECT tag FROM rel_user_tag WHERE login = ?', [login], cb);
};

model.removeTag = (login, tag, cb) => {
	connection.query('DELETE FROM rel_user_tag WHERE login = ? AND tag = ?', [login, tag], cb);
};


module.exports = model;
