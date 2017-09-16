var mysql = require('mysql');

var connection = mysql.createConnection({
	host     : 'localhost',
	user     : 'jubarbie',
	password : '',
	multipleStatements : true,
	socketPath: '/tmp/mysql.sock'
});

var create_database = 'DROP DATABASE IF EXISTS matcha_db ;';
create_database += 'CREATE DATABASE matcha_db ;';
create_database += 'CREATE TABLE matcha_db.user (id INT(6) UNSIGNED AUTO_INCREMENT PRIMARY KEY, login VARCHAR(255), password TEXT, fname VARCHAR(255) NOT NULL, lname VARCHAR(255) NOT NULL, email VARCHAR(255), gender VARCHAR(1),  interested_in VARCHAR(15), bio TEXT ) ;';
create_database += 'INSERT INTO matcha_db.user (fname, lname, email, gender, interested_in, bio) VALUES ("Henry", "Niseau", "hniseau@student.42.fr", "M", "F", "Étudiant studieux, je privilégie les rencontres réelles au virtuel. On va boire un café?") ;';
create_database += 'INSERT INTO matcha_db.user (fname, lname, email, gender, interested_in, bio) VALUES ("Marie", "Debord", "mdebord@student.42.fr", "F", "F", "Pour rencontre d\'un soir") ;';
create_database += 'INSERT INTO matcha_db.user (fname, lname, email, gender, interested_in, bio) VALUES ("Yassine", "Drissi", "yadrissi@student.42.fr", "M", "M", "Ask me") ;';
create_database += 'INSERT INTO matcha_db.user (fname, lname, email, gender, interested_in, bio) VALUES ("Mariana", "Marquês", "mmarques@student.42.fr", "F", "M", "Cherche mon prince charmant") ;';

connection.query(create_database, function(err, rows, fields) {
	connection.end();
	if (!err)
	    console.log('Database matcha_db created', rows);
	else
	    console.log('Error while creating database', err);
});

module.exports = mysql;

