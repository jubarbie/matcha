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
var create_database = "";
if (process.argv.length == 3) {
    let db = fs.readFileSync(process.argv[2], "utf8");
    create_database += "DROP DATABASE IF EXISTS matcha_db;\
    CREATE DATABASE matcha_db;\
    USE matcha_db;"
    create_database += db;
} else {
    create_database += fs.readFileSync('./matcha_db.sql', "utf8");
}


connection.query(create_database, function(err, rows, fields) {
    connection.end();
    if (!err) {
        console.log('Database created');
    } else {
        console.log('Error while creating database', err);
    }
});
