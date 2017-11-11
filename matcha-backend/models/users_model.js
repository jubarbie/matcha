var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getAllUsers = function(cb) {
	connection.query('\
		SELECT u.*, GROUP_CONCAT(i.src) AS photos \
			FROM user AS u \
			LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
			LEFT JOIN image AS i ON i.id = rel.id_image \
			GROUP BY u.id'
	, cb);
}

model.getRelevantProfiles = function(gender, int_in, cb) {
	connection.query('\
		SELECT u.*, GROUP_CONCAT(i.src) AS photos \
			FROM user AS u \
			LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
			LEFT JOIN image AS i ON i.id = rel.id_image \
			WHERE u.gender = ? \
			AND u.interested_in = ? \
			GROUP BY u.id'
	, [gender, int_in], cb);
}

model.getUserWithLogin = function(login, cb) {
	connection.query('SELECT * FROM user WHERE login = ?', [login], cb);
}

model.deleteUser = function(login, cb) {
	connection.query('DELETE FROM user WHERE login = ?', [login], cb);
}

model.activatedUserWithLogin = function(login, cb) {
	connection.query('UPDATE user SET activated="activated" WHERE login = ?', [login], cb);
}

model.getTokenFromLogin = function(login, cb) {
	connection.query('SELECT activated FROM user WHERE login = ?', [login], cb);
}

model.insertUser = function(user, date, cb) {
	connection.query('INSERT INTO user (login, email, fname, lname, password, gender, interested_in, bio, activated, rights, created_on) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [user.login, user.email, user.fname, user.lname, user.password, user.gender, user.int_in, user.bio, user.activated, user.rights, date], cb);
}

model.updateInfos = function(login, infos, cb) {
	connection.query('UPDATE user SET email = ?, fname = ?, lname = ?, gender = ?, interested_in = ?, bio = ? WHERE login = ?', [infos.email, infos.fname, infos.lname, infos.gender, infos.int_in, infos.bio, login], cb);
}

model.updateLocation = function(login, loc, cb) {
	connection.query('UPDATE user SET localisation = ? WHERE login = ?', [loc, login], cb);
}

module.exports = model;
