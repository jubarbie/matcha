const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.getAllUsers = (cb) =>
    connection.query('\
		SELECT u.*, GROUP_CONCAT(DISTINCT i.src) AS photos \
			FROM user AS u \
			LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
			LEFT JOIN image AS i ON i.id = rel.id_image \
			GROUP BY u.id', cb);

exports.getRelevantProfiles = (logged, gender, int_in, cb) =>
    connection.query('\
		SELECT u.login AS login, u.birth AS birth, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, \
    ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
    ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
    ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
		GROUP_CONCAT(DISTINCT i.src) AS photos, \
    GROUP_CONCAT(DISTINCT relt.tag) AS tags, \
    GROUP_CONCAT(DISTINCT v.user_from) AS visitor \
			FROM user AS u \
			LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
			INNER JOIN image AS i ON i.id = rel.id_image \
			LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
			LEFT JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
			JOIN sex_orientation AS s ON u.login = s.login \
			WHERE u.gender IN (?) \
      AND NOT EXISTS ( SELECT reports.id FROM reports WHERE reports.user_to = u.login ) \
      AND NOT EXISTS ( SELECT blocks.id FROM blocks WHERE ( blocks.user_to = u.login AND blocks.user_from = ? ) OR ( blocks.user_to = ? AND blocks.user_from = u.login ) ) \
			AND s.gender = ? \
			AND (u.activated = "activated" OR u.activated = "resetpwd") \
			AND u.login != ? \
			GROUP BY u.id', [logged, logged, logged, gender, logged, logged, int_in, logged], cb);

exports.getVisitors = (logged, gender, int_in, cb) =>
    connection.query('\
			SELECT u.login AS login, u.birth AS birth, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, u.localisation AS localisation, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
      GROUP_CONCAT(DISTINCT i.src) AS photos, \
      GROUP_CONCAT(DISTINCT relt.tag) AS tags \
				FROM user AS u \
				LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
				LEFT JOIN image AS i ON i.id = rel.id_image \
				LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
				JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
				JOIN sex_orientation AS s ON u.login = s.login \
				WHERE u.gender IN (?) \
        AND NOT EXISTS ( SELECT reports.id FROM reports WHERE reports.user_to = u.login ) \
        AND NOT EXISTS ( SELECT blocks.id FROM blocks WHERE ( blocks.user_to = u.login AND blocks.user_from = ? ) OR ( blocks.user_to = ? AND blocks.user_from = u.login ) ) \
				AND v.user_to = ? \
				AND s.gender = ? \
				AND (u.activated = "activated" OR u.activated = "resetpwd") \
				AND u.login != ? \
				GROUP BY u.id', [logged, logged, logged, gender, logged, logged, logged, int_in, logged], cb);

exports.getLikers = (logged, gender, int_in, cb) =>
    connection.query('\
					SELECT u.login AS login, u.birth AS birth, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, u.localisation AS localisation, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
          GROUP_CONCAT(DISTINCT i.src) AS photos, \
          GROUP_CONCAT(DISTINCT relt.tag) AS tags \
						FROM user AS u \
						LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
						LEFT JOIN image AS i ON i.id = rel.id_image \
						LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
						JOIN likes AS l ON l.user_to = ? AND l.user_from = u.login \
						JOIN sex_orientation AS s ON u.login = s.login \
						WHERE u.gender IN (?) \
            AND NOT EXISTS ( SELECT reports.id FROM reports WHERE reports.user_to = u.login ) \
            AND NOT EXISTS ( SELECT blocks.id FROM blocks WHERE ( blocks.user_to = u.login AND blocks.user_from = ? ) OR ( blocks.user_to = ? AND blocks.user_from = u.login ) ) \
						AND l.user_to = ? \
						AND s.gender = ? \
						AND (u.activated = "activated" OR u.activated = "resetpwd") \
						AND u.login != ? \
						GROUP BY u.id', [logged, logged, logged, gender, logged, logged, logged, int_in, logged], cb);

exports.getFullDataUserWithLogin = (logged, login, cb) =>
    connection.query('\
		SELECT u.login AS login, u.birth AS birth, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, \
    GROUP_CONCAT(DISTINCT i.src) AS photos, \
    ( SELECT COUNT(talk.id) FROM talk WHERE username1 = ? AND username2 = ? ) AS talks, GROUP_CONCAT(DISTINCT relt.tag) AS tags, \
    ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
    ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
    ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
		GROUP_CONCAT(DISTINCT s.gender) AS interested_in, \
    GROUP_CONCAT(DISTINCT v.user_from) AS visitor \
		FROM user AS u \
		LEFT JOIN rel_user_image AS rel ON rel.id_user = u.id \
		LEFT JOIN image AS i ON i.id = rel.id_image \
		LEFT JOIN sex_orientation AS s ON u.login = s.login \
		LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
		LEFT JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
		WHERE u.login = ? \
		GROUP BY u.id', [...[logged, login].sort(), logged, logged, logged, login, logged], cb);

exports.getUserWithLogin = (login, cb) =>
    connection.query(' \
		SELECT u.*, GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT relt.tag) AS tags  \
		FROM user AS u \
		LEFT JOIN sex_orientation AS s ON s.login = u.login \
		LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
		WHERE u.login = ? \
		GROUP BY u.id \
		', [login], cb);

exports.getUserWithLoginAndEmail = (login, email, cb) =>
    connection.query('SELECT * FROM user WHERE login = ? AND email = ?', [login, email], cb);

exports.deleteUser = (login, cb) =>
    connection.query('DELETE FROM user WHERE login = ?', [login], cb);

exports.activateUserWithLogin = (login, activated, cb) =>
    connection.query('UPDATE user SET activated = ? WHERE login = ?', [activated, login], cb);

exports.getTokenFromLogin = (login, cb) =>
    connection.query('SELECT activated FROM user WHERE login = ?', [login], cb);

exports.insertUser = (user, date, cb) =>
    connection.query('\
		INSERT INTO user (login, email, fname, lname, password, gender, bio, activated, rights, created_on, last_connection) \
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)', [user.login, user.email, user.fname, user.lname, user.password, user.gender, user.bio, user.activated, user.rights, date], cb);

exports.updateInfos = (login, infos, activated, cb) =>
    connection.query('\
		UPDATE user SET email = ?, fname = ?, lname = ?, bio = ?, activated = ? \
		WHERE login = ? ', [infos.email, infos.fname, infos.lname, infos.bio, activated, login], cb);

exports.updateConnectionDate = (id, date, cb) =>
    connection.query('UPDATE user SET last_connection = ? WHERE id = ?', [date, id], cb);

exports.updateLocation = (login, loc, cb) =>
    connection.query('UPDATE user SET localisation = ? WHERE login = ?', [loc, login], cb);

exports.updatePassword = (login, password, activated, cb) =>
    connection.query('UPDATE user SET password = ?, activated = ? WHERE login = ?', [password, activated, login], cb);

exports.updateField = (login, field, value, cb) =>
    connection.query('UPDATE user SET ?? = ? WHERE login = ?', [field, value, login], cb);

exports.updateSexuality = (login, genders, cb) => {
    connection.query('DELETE FROM sex_orientation WHERE login = ?', [login], (err, rows, fields) => {
        if (genders.length > 0)
            connection.query('INSERT INTO sex_orientation (login, gender) VALUES ? ', [genders], cb);
        else
          cb();
    })
}
