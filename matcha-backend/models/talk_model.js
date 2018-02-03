var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getTalkFromUsers = (username1, username2, cb) => {
	connection.query('SELECT * FROM talk WHERE username1 = ? AND username2 = ?', [username1, username2], cb);
};

model.newTalk = (username1, username2, date, cb) => {
	connection.query('INSERT INTO talk (username1, username2, user1_last, user2_last) VALUES ( ?, ?, ?, ?)', [username1, username2, date, date], cb);
};

model.newMessage = (id_talk, message, username, date, cb) => {
	connection.query('INSERT INTO message (username, message, id_talk, date) VALUES ( ?, ?, ?, ?)', [username, message, id_talk, date], cb);
};

model.getUserTalks = (username, cb) => {
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

model.getTalkMessages = (id, user, cb) => {
	var query = ' \
		SELECT ( \
			SELECT COUNT(message.id) FROM message \
			INNER JOIN talk ON talk.id=message.id_talk \
			WHERE talk.id = ? AND ?? < date \
		) as unread, message.* \
		FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.id = ? ORDER BY message.date DESC LIMIT 50';
	connection.query(query, [id, user, id], cb);
};

model.getUnseenMessagesForTalk = (talk_id, user, cb) => {
	connection.query('SELECT COUNT(message.id) AS unread FROM message INNER JOIN talk ON talk.id=message.id_talk WHERE talk.id = ? AND ?? < date', [talk_id, user], cb);
}

model.updateLast = (id, user, date) => {
	connection.query('UPDATE talk SET ?? = ? WHERE id = ?', [user, date, id]);
}

model.removeTalk = (id) => {
	connection.query('DELETE FROM message WHERE id_talk = ?', [id]);
	connection.query('DELETE FROM talk WHERE id = ?', [id]);
};

module.exports = model;
