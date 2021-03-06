const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.getAllUsers = (cb) =>
    connection.query('\
  		SELECT u.* \
  			FROM user AS u \
  			', cb);

exports.getAdvanceSearch = (logged, gender, int_in, searchLogin, searchTags, yearMin, yearMax, cb) => {
    var tagOperator = (searchTags.length == 0) ? 'NOT IN' : 'IN';
    searchTags = (searchTags.length == 0) ? ['='] : searchTags;
    connection.query('\
      SELECT u.login AS login, u.birth AS birth, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, \
      CASE WHEN u.uuid IS NULL THEN 0 ELSE 1 END AS online, \
      ( SELECT COUNT(visits.id) FROM visits WHERE visits.user_to = u.login ) AS visits, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
      (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
        FROM image \
        JOIN rel_user_image ON image.id=rel_user_image.id_image \
        LEFT JOIN user ON user.id = rel_user_image.id_user \
        WHERE rel_user_image.id_user = u.id) AS images, \
      GROUP_CONCAT(DISTINCT relt.tag) AS tags, \
      GROUP_CONCAT(DISTINCT v.user_from) AS visitor \
        FROM user AS u \
        LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
        LEFT JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
        JOIN sex_orientation AS s ON u.login = s.login \
        WHERE u.gender IN (?) \
        AND u.birth >= ? \
        AND u.birth <= ? \
        AND u.login LIKE ? \
        AND relt.tag ' + tagOperator + ' (?) \
        AND NOT EXISTS ( SELECT reports.id FROM reports WHERE reports.user_to = u.login ) \
        AND NOT EXISTS ( SELECT blocks.id FROM blocks WHERE ( blocks.user_to = u.login AND blocks.user_from = ? ) OR ( blocks.user_to = ? AND blocks.user_from = u.login ) ) \
        AND s.gender = ? \
        AND (u.activated = "activated" OR u.activated = "resetpwd") \
        AND u.login != ? \
        GROUP BY u.id', [logged, logged, logged, gender, yearMin, yearMax, searchLogin + "%", searchTags, logged, logged, int_in, logged], cb);
}

exports.getRelevantProfiles = (logged, gender, int_in, cb) =>
    connection.query('\
        SELECT u.login AS login, u.birth AS birth, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, \
        CASE WHEN u.uuid IS NULL THEN 0 ELSE 1 END AS online, \
        ( SELECT COUNT(visits.id) FROM visits WHERE visits.user_to = u.login ) AS visits, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
      GROUP_CONCAT(DISTINCT relt.tag) AS tags, \
      GROUP_CONCAT(DISTINCT v.user_from) AS visitor, \
      (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
  	 	  FROM image \
  	 	  JOIN rel_user_image ON image.id=rel_user_image.id_image \
  		  LEFT JOIN user ON user.id = rel_user_image.id_user \
  		  WHERE rel_user_image.id_user = u.id) AS images \
  		FROM user AS u \
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
            CASE WHEN u.uuid IS NULL THEN 0 ELSE 1 END AS online, \
      ( SELECT COUNT(visits.id) FROM visits WHERE visits.user_to = u.login ) AS visits, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
      ( SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
        FROM image \
        JOIN rel_user_image ON image.id=rel_user_image.id_image \
        LEFT JOIN user ON user.id = rel_user_image.id_user \
        WHERE rel_user_image.id_user = u.id) AS images, \
      ( SELECT GROUP_CONCAT(DISTINCT relt.tag) FROM rel_user_tag AS relt WHERE relt.login = u.login ) AS tags   \
				FROM user AS u \
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
                    CASE WHEN u.uuid IS NULL THEN 0 ELSE 1 END AS online, \
          ( SELECT COUNT(visits.id) FROM visits WHERE visits.user_to = u.login ) AS visits, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
          (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
      	 	  FROM image \
      	 	  JOIN rel_user_image ON image.id=rel_user_image.id_image \
      		  LEFT JOIN user ON user.id = rel_user_image.id_user \
      		  WHERE rel_user_image.id_user = u.id) AS images, \
          GROUP_CONCAT(DISTINCT relt.tag) AS tags \
						FROM user AS u \
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

exports.getMatchers = (logged, gender, int_in, cb) =>
    connection.query('\
					SELECT u.login AS login, u.birth AS birth, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, u.localisation AS localisation, \
                    CASE WHEN u.uuid IS NULL THEN 0 ELSE 1 END AS online, \
          ( SELECT COUNT(visits.id) FROM visits WHERE visits.user_to = u.login ) AS visits, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
          ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
          (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
      	 	  FROM image \
      	 	  JOIN rel_user_image ON image.id=rel_user_image.id_image \
      		  LEFT JOIN user ON user.id = rel_user_image.id_user \
      		  WHERE rel_user_image.id_user = u.id) AS images, \
          GROUP_CONCAT(DISTINCT relt.tag) AS tags \
						FROM user AS u \
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
            AND EXISTS ( SELECT likes.id FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) \
						GROUP BY u.id', [logged, logged, logged, gender, logged, logged, logged, int_in, logged, logged], cb);

exports.getFullDataUserWithLogin = (logged, login, cb) =>
    connection.query('\
  		SELECT u.login AS login, u.birth AS birth, u.localisation AS localisation, u.gender AS gender, u.bio AS bio, u.last_connection AS last_connection, \
        CASE WHEN u.uuid IS NULL THEN 0 ELSE 1 END AS online, \
        (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
          FROM image \
          JOIN rel_user_image ON image.id=rel_user_image.id_image \
          LEFT JOIN user ON user.id = rel_user_image.id_user \
          WHERE rel_user_image.id_user = u.id) AS images, \
      ( SELECT COUNT(talk.id) FROM talk WHERE username1 = ? AND username2 = ? ) AS talks, GROUP_CONCAT(DISTINCT relt.tag) AS tags, \
      ( SELECT COUNT(visits.id) FROM visits WHERE visits.user_to = u.login ) AS visits, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_to = u.login ) AS likes, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = ? AND likes.user_to = u.login ) AS liking, \
      ( SELECT COUNT(likes.id) FROM likes WHERE likes.user_from = u.login AND likes.user_to = ? ) AS liked, \
  		GROUP_CONCAT(DISTINCT s.gender) AS interested_in, \
      GROUP_CONCAT(DISTINCT v.user_from) AS visitor \
    		FROM user AS u \
    		LEFT JOIN sex_orientation AS s ON u.login = s.login \
    		LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
    		LEFT JOIN visits AS v ON v.user_to = ? AND v.user_from = u.login \
    		WHERE u.login = ? \
    		GROUP BY u.id', [...[logged, login].sort(), logged, logged, logged, login, logged], cb);

exports.getUserWithLogin = (login, cb) =>
    connection.query(' \
    		SELECT u.id, u.password, u.login, u.fname, u.lname, u.email, u.gender, u.bio, u.activated, u.rights, u.localisation, u.last_connection, u.birth, GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT relt.tag) AS tags,  \
        (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
    	 	  FROM image \
    	 	  JOIN rel_user_image ON image.id=rel_user_image.id_image \
    		  LEFT JOIN user ON user.id = rel_user_image.id_user \
    		  WHERE rel_user_image.id_user = u.id) AS images, \
        (SELECT GROUP_CONCAT(f.username,";",f.unread) \
          FROM ( \
            SELECT t.username2 AS username, \
        			(SELECT COUNT(message.id) FROM message WHERE id_talk=t.id AND date > t.user1_last AND message.username <> t.username1) AS unread \
        		FROM talk AS t \
        		WHERE t.username1 = ? \
        		AND NOT EXISTS ( SELECT * FROM blocks WHERE (blocks.user_to = t.username2 AND blocks.user_from = t.username1) OR (blocks.user_to = t.username1 AND blocks.user_from = t.username2)) \
        		UNION \
        		SELECT t.username1 AS username, \
        			(SELECT COUNT(message.id) FROM message WHERE id_talk=t.id AND date > t.user2_last AND message.username <> t.username2) AS unread \
        		FROM talk AS t \
        		WHERE t.username2 = ? \
        		AND NOT EXISTS ( SELECT * FROM blocks WHERE (blocks.user_to = t.username1 AND blocks.user_from = t.username2) OR (blocks.user_to = t.username2 AND blocks.user_from = t.username1)) \
          ) AS f \
          ) AS talks \
    		FROM user AS u \
    		LEFT JOIN sex_orientation AS s ON s.login = u.login \
        LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
    		WHERE u.login = ? \
    		GROUP BY u.id \
      		', [login, login, login], cb);

exports.getAllProfiles = (cb) =>
    connection.query(' \
    		SELECT u.id, u.password, u.login, u.fname, u.lname, u.email, u.gender, u.bio, u.activated, u.rights, u.localisation, u.last_connection, u.birth, GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT relt.tag) AS tags,  \
        (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
    	 	  FROM image \
    	 	  JOIN rel_user_image ON image.id=rel_user_image.id_image \
    		  LEFT JOIN user ON user.id = rel_user_image.id_user \
    		  WHERE rel_user_image.id_user = u.id) AS images \
    		FROM user AS u \
    		LEFT JOIN sex_orientation AS s ON s.login = u.login \
        LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
    		GROUP BY u.id \
      		', [], cb);

exports.getReportedUsers = (cb) =>
  connection.query(' \
    SELECT u.id, u.password, u.login, u.fname, u.lname, u.email, u.gender, u.bio, u.activated, u.rights, u.localisation, u.last_connection, u.birth, GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT relt.tag) AS tags,  \
    (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
      FROM image \
      JOIN rel_user_image ON image.id=rel_user_image.id_image \
      LEFT JOIN user ON user.id = rel_user_image.id_user \
      WHERE rel_user_image.id_user = u.id) AS images, \
    (SELECT GROUP_CONCAT(DISTINCT rp.user_from)) AS reports \
    FROM user AS u \
    LEFT JOIN sex_orientation AS s ON s.login = u.login \
    LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
    JOIN reports AS rp ON rp.user_to = u.login \
    GROUP BY u.id \
      ', [], cb);

exports.getUserWithUuid = (id, cb) =>
    connection.query(' \
      SELECT u.id, u.password, u.login, u.fname, u.lname, u.email, u.gender, u.bio, u.activated, u.rights, u.localisation, u.last_connection, u.birth, GROUP_CONCAT(DISTINCT s.gender) AS interested_in, GROUP_CONCAT(DISTINCT relt.tag) AS tags,  \
      (SELECT GROUP_CONCAT(image.id, ";", image.src, ";", CASE WHEN image.id=user.img_id THEN true ELSE false END) \
        FROM image \
        JOIN rel_user_image ON image.id=rel_user_image.id_image \
        LEFT JOIN user ON user.id = rel_user_image.id_user \
        WHERE rel_user_image.id_user = u.id) AS images \
      FROM user AS u \
      LEFT JOIN sex_orientation AS s ON s.login = u.login \
      LEFT JOIN rel_user_tag AS relt ON relt.login = u.login \
      WHERE u.uuid = ? \
      GROUP BY u.id \
      		', [id], cb);

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
		INSERT INTO user (login, email, fname, lname, password, activated, rights, created_on, last_connection) \
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0)', [user.login, user.email, user.fname, user.lname, user.password, user.activated, user.rights, date], cb);

exports.insertFullUser = (user, date, cb) =>
    connection.query('\
		INSERT INTO user (login, email, fname, lname, password, gender, bio, activated, rights, created_on, localisation, birth, last_connection) \
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 0)', [user.login, user.email, user.fname, user.lname, user.password, user.gender, user.bio, user.activated, user.rights, date, user.localisation, user.birth], cb);

exports.updateInfos = (login, infos, activated, cb) =>
    connection.query('\
		UPDATE user SET email = ?, fname = ?, lname = ?, bio = ?, activated = ? \
		WHERE login = ? ', [infos.email, infos.fname, infos.lname, infos.bio, activated, login], cb);

exports.updateConnectionDate = (id, date, uuid, cb) =>
    connection.query('UPDATE user SET last_connection = ?, uuid = ? WHERE id = ?', [date, uuid, id], cb);

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
};

exports.getBlocked = (from, to, cb) =>
    connection.query('SELECT * FROM blocks WHERE (user_from = ? AND user_to = ?) OR (user_from = ? AND user_to = ?)', [from, to, to, from], cb);
