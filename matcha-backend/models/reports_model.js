const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.addReport = (from, to, date, cb) => {
    if (from !== to) {
      connection.query('SELECT * FROM reports WHERE user_from = ? AND user_to = ? ', [from, to], (err, rows, fields) => {
          if (!err && rows.length == 0) {
              connection.query('INSERT INTO reports (user_from, user_to, date) VALUES (?,?,?) ', [from, to, date], cb);
          } else {
              cb();
          }
      });
    } else {
      cb();
    }
}

exports.addBlock = (from, to, date, cb) => {
    if (from !== to) {
      connection.query('SELECT * FROM blocks WHERE user_from = ? AND user_to = ? ', [from, to], (err, rows, fields) => {
          if (!err && rows.length == 0) {
              connection.query('INSERT INTO blocks (user_from, user_to, date) VALUES (?,?,?) ', [from, to, date], cb);
          } else {
              cb();
          }
      });
    } else {
      cb();
    }
}
