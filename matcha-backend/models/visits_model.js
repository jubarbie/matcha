const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.addVisit = (from, to, date, cb) => {
    if (from != to) {
      connection.query('SELECT * FROM visits WHERE user_from = ? AND user_to = ? ', [from, to], (err, rows, fields) => {
          if (!err && rows.length == 0) {
              connection.query('INSERT INTO visits (user_from, user_to, date, last) VALUES (?,?,?,0) ', [from, to, date], cb);
          } else {
              cb();
          }
      });
    } else {
      cb();
    }
}

exports.updateVisitLast = (to, date) =>
    connection.query('UPDATE visits SET last = ? WHERE user_to = ?', [date, to]);

exports.getNotifVisit = (logged, cb) =>
    connection.query('SELECT user_from FROM visits WHERE user_to = ? AND last < date', [logged], cb);
