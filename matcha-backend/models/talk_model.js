const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.getTalkFromUsers = (username1, username2, cb) => {
	connection.query('SELECT * FROM talk WHERE username1 = ? AND username2 = ?', [username1, username2], cb);
};

exports.newTalk = (username1, username2, date, cb) => {
	connection.query('INSERT INTO talk (username1, username2, user1_last, user2_last) VALUES ( ?, ?, ?, ?)', [username1, username2, date, date], cb);
};

exports.newMessage = (id_talk, message, username, date, cb) => {
	connection.query('INSERT INTO message (username, message, id_talk, date) VALUES ( ?, ?, ?, ?)', [username, message, id_talk, date], cb);
};

exports.getUserTalks = (username, cb) => {
	connection.query(' \
		SELECT t.username2 AS username, \
			(SELECT COUNT(message.id) FROM message WHERE id_talk=t.id AND date > t.user1_last AND message.username <> ?) AS unread \
		FROM talk AS t \
		WHERE t.username1 = ? \
		UNION \
		SELECT t.username1 AS username, \
			(SELECT COUNT(message.id) FROM message WHERE id_talk=t.id AND date > t.user2_last AND message.username <> ?) AS unread \
		FROM talk AS t \
		WHERE t.username2 = ? \
		', [username, username, username, username], cb);
};

exports.getTalkMessages = (id, user, cb) => {
	var query = ' \
		SELECT ( \
			SELECT COUNT(message.id) FROM message \
			INNER JOIN talk ON talk.id=message.id_talk \
			WHERE talk.id = ? AND ?? < date \
		) as unread, message.* \
		FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.id = ? ORDER BY message.date DESC LIMIT 50';
	connection.query(query, [id, user, id], cb);
};

exports.getUnseenMessagesForTalk = (talk_id, user, cb) => {
	connection.query('SELECT COUNT(message.id) AS unread FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.id = ? AND ?? < date', [talk_id, user], cb);
}

exports.getTalkNotif = (users, user, cb) => {
	connection.query('SELECT COUNT(message.id) AS unread FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.username1 = ? AND talk.username2 = ? AND ?? < date', [users[0], users[1], user], cb);
}

exports.updateLast = (id, user, date) => {
	connection.query('UPDATE talk SET ?? = ? WHERE id = ?', [user, date, id]);
}

exports.removeTalk = (id) => {
	connection.query('DELETE FROM message WHERE id_talk = ?', [id]);
	connection.query('DELETE FROM talk WHERE id = ?', [id]);
};
