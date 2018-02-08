const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.getNumberOfLikes = (username, cb) =>
    connection.query('SELECT COUNT(*) FROM likes WHERE user_to = ?', [username], cb);

exports.like = (user_from, user_to, date, cb) =>
    connection.query('INSERT INTO likes (user_from, user_to, date, last) VALUES ( ?, ?, ?, 0)', [user_from, user_to, date], cb);

exports.unLike = (user_from, user_to, cb) =>
    connection.query('DELETE FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);

exports.getLikeBetweenUsers = (user_from, user_to, cb) =>
    connection.query('SELECT * FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);

exports.updateLikeLast = (to, date) =>
    connection.query('UPDATE likes SET last = ? WHERE user_to = ?', [date, to]);

exports.getNotifLike = (logged, cb) =>
    connection.query('SELECT COUNT(id) AS notif FROM likes WHERE user_to = ? AND last < date', [logged], cb);
