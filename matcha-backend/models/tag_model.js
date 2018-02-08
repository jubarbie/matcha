const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.searchTags = (search, cb) =>
	connection.query('SELECT DISTINCT tag FROM rel_user_tag WHERE tag LIKE ? LIMIT 10', [search], cb);

exports.addTag = (login, tag, cb) =>
	connection.query(' \
		INSERT INTO rel_user_tag (login , tag) \
		SELECT ?, ? \
 		WHERE NOT EXISTS (SELECT login, tag FROM rel_user_tag \
									 WHERE login = ? AND tag = ?) \
		', [ login, tag, login, tag  ], cb);

exports.getTagsFromLogin = (login, cb) =>
	connection.query('SELECT tag FROM rel_user_tag WHERE login = ?', [login], cb);

exports.removeTag = (login, tag, cb) =>
	connection.query('DELETE FROM rel_user_tag WHERE login = ? AND tag = ?', [login, tag], cb);
