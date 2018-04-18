var mysql = require('mysql');
var config = require('./config');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var jwt = require('jsonwebtoken');
var UsersModel = require('./models/users_model');

var db = config.database;
var connection = mysql.createConnection({
    host: db.host,
    port: db.port,
    user: db.user,
    password: db.password,
    insecureAuth: true,
    multipleStatements: true,
});

var fs = require('fs');
var create_database = fs.readFileSync('./matcha_db.sql', "utf8");

connection.query(create_database, function(err, rows, fields) {
    connection.end();
    if (!err) {
        console.log('Database created');
    } else {
        console.log('Error while creating database', err);
    }
});