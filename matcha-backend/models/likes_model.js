const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

class Database {
    constructor( config ) {
        this.connection = mysql.createConnection( config );
    }
    query( sql, args ) {
        return new Promise( ( resolve, reject ) => {
            this.connection.query( sql, args, ( err, rows ) => {
                if ( err )
                    return reject( err );
                resolve( rows );
            } );
        } );
    }
    close() {
        return new Promise( ( resolve, reject ) => {
            this.connection.end( err => {
                if ( err )
                    return reject( err );
                resolve();
            } );
        } );
    }
}

exports.getNumberOfLikes = (username, cb) =>
    connection.query('SELECT COUNT(*) FROM likes WHERE user_to = ?', [username], cb);

exports.like = (user_from, user_to, date, cb) =>
    connection.query('INSERT INTO likes (user_from, user_to, date, last) VALUES ( ?, ?, ?, 0)', [user_from, user_to, date], cb);

exports.removeLike = (user_from, user_to, cb) =>
    connection.query('DELETE FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);

exports.unLike = (user_from, user_to, date, cb) =>
    connection.query('INSERT INTO unlikes (user_from, user_to, date, last) VALUES ( ?, ?, ?, 0)', [user_from, user_to, date], cb);

exports.removeUnLike = (user_from, user_to, cb) =>
    connection.query('DELETE FROM unlikes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);

exports.getLikeBetweenUsers = (user_from, user_to, cb) =>
    connection.query('SELECT * FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to], cb);

exports.updateLikeLast = (to, date) =>
    connection.query('UPDATE likes SET last = ? WHERE user_to = ?', [date, to]);

exports.getNotifLike = (logged, cb) =>
    connection.query('SELECT user_from FROM likes WHERE user_to = ? AND last < date', [logged], cb);

exports.getNotifUnLike = (logged, cb) =>
    connection.query('SELECT user_from FROM unlikes WHERE user_to = ? AND last < date', [logged], cb);

exports.getLikeBetweenUsersAsync = (user_from, user_to) => {
    let database = new Database(config.database);
    let ret;
    database.query('SELECT * FROM likes WHERE user_from = ? AND user_to = ?', [user_from, user_to]).then( rows => {
      ret = (rows.length > 0);
      return database.close();
    }).then( () => {
      return ret;
    });
}
