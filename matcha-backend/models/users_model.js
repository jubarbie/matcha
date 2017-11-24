var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getAllUsers = (cb) =>
	connection.query('\
		SELECT u.*, GROUP_CONCAT(DISTINCT i.src) AS photos \
			FROM user AS u \
			LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
			LEFT JOIN image AS i ON i.id = rel.id_image \
			GROUP BY u.id'
	, cb);

model.getRelevantProfiles = (logged, gender, int_in, cb) =>
	connection.query('\
		SELECT u.login AS login, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, \
		GROUP_CONCAT(DISTINCT i.src) AS photos, GROUP_CONCAT(DISTINCT relt.tag) AS tags, GROUP_CONCAT(DISTINCT v.user_from) AS visitor \
			FROM user AS u \
			LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
			LEFT JOIN image AS i ON i.id = rel.id_image \
			LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
			LEFT JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
			JOIN sex_orientation AS s ON u.login = s.login \
			WHERE u.gender IN (?) \
			AND s.gender = ? \
			AND (u.activated = "activated" OR u.activated = "resetpwd") \
			AND u.login != ? \
			GROUP BY u.id'
	, [logged, gender, int_in, logged], cb);

	model.getVisitors = (logged, gender, int_in, cb) =>
		connection.query('\
			SELECT u.login AS login, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, GROUP_CONCAT(DISTINCT i.src) AS photos, GROUP_CONCAT(DISTINCT relt.tag) AS tags \
				FROM user AS u \
				LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
				LEFT JOIN image AS i ON i.id = rel.id_image \
				LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
				JOIN visits AS v ON v.user_to = u.login \
				JOIN sex_orientation AS s ON u.login = s.login \
				WHERE u.gender IN (?) \
				AND s.gender = ? \
				AND (u.activated = "activated" OR u.activated = "resetpwd") \
				AND u.login != ? \
				GROUP BY u.id'
		, [gender, int_in, logged], cb);

model.getFullDataUserWithLogin = (logged, login, cb) =>
	connection.query('\
		SELECT u.login AS login, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, GROUP_CONCAT(DISTINCT i.src) AS photos, \
			( SELECT COUNT(talk.id) FROM talk WHERE username1 = ? AND username2 = ? ) AS talks, GROUP_CONCAT(DISTINCT relt.tag) AS tags, \
			GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT v.user_from) AS visitor \
		FROM user AS u \
		LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
		LEFT JOIN image AS i ON i.id = rel.id_image \
		LEFT JOIN sex_orientation AS s ON u.login = s.login \
		LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
		LEFT JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
		WHERE u.login = ? \
		GROUP BY u.id'
	, [...[logged, login].sort(), logged, login], cb);

model.getUserWithLogin = (login, cb) =>
	connection.query(' \
		SELECT u.*, GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT relt.tag) AS tags  \
		FROM user AS u \
		LEFT JOIN sex_orientation AS s ON s.login = u.login \
		LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
		WHERE u.login = ? \
		GROUP BY u.id \
		', [login], cb);


model.getUserWithLoginAndEmail = (login, email, cb) =>
	connection.query('SELECT * FROM user WHERE login = ? AND email = ?', [login, email], cb);

model.deleteUser = (login, cb) =>
	connection.query('DELETE FROM user WHERE login = ?', [login], cb);

model.activateUserWithLogin = (login, activated, cb) =>
	connection.query('UPDATE user SET activated = ? WHERE login = ?', [activated, login], cb);

model.getTokenFromLogin = (login, cb) =>
	connection.query('SELECT activated FROM user WHERE login = ?', [login], cb);

model.insertUser = (user, date, cb) =>
	connection.query('\
		INSERT INTO user (login, email, fname, lname, password, gender, interested_in, bio, activated, rights, created_on) \
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)'
		, [user.login, user.email, user.fname, user.lname, user.password, user.gender, user.int_in, user.bio, user.activated, user.rights, date], cb);

model.updateInfos = (login, infos, cb) =>
	connection.query('\
		UPDATE user SET email = ?, fname = ?, lname = ?, bio = ? \
		WHERE login = ? '
		, [infos.email, infos.fname, infos.lname, infos.bio, login], cb);

model.updateConnectionDate = (id, date, cb) =>
	connection.query('UPDATE user SET last_connection = ? WHERE id = ?', [date, id], cb);

model.updateLocation = (login, loc, cb) =>
	connection.query('UPDATE user SET localisation = ? WHERE login = ?', [loc, login], cb);

model.updatePassword = (login, password, activated, cb) =>
	connection.query('UPDATE user SET password = ?, activated = ? WHERE login = ?', [password, activated, login], cb);

model.updateField = (login, field, value, cb) =>
	connection.query('UPDATE user SET ?? = ? WHERE login = ?', [field, value, login], cb);

model.updateSexuality = (login, genders, cb) => {
		connection.query('DELETE FROM sex_orientation WHERE login = ?', [login], (err, rows, fields) => {
			if (genders.length > 0)
			connection.query('INSERT INTO sex_orientation (login, gender) VALUES ? ', [genders], cb); })
}

model.addVisit = (from, to, cb) => {
	connection.query('SELECT * FROM visits WHERE user_from = ? AND user_to = ? ', [from, to], (err, rows, fields) => {
		if (!err && rows.length == 0) {
			connection.query('INSERT INTO visits (user_from, user_to) VALUES (?,?) ', [from, to], cb);
		} else {
			cb();
		}
	});
}

module.exports = model;
