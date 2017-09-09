var express = require('express');
var router = express.Router();

var mysql = require('mysql');

var connection = mysql.createConnection({
	host     : 'localhost',
	user     : 'jubarbie',
	password : '',
	database : 'matcha_db',
	socketPath: '/tmp/mysql.sock'
});


/* GET users listing. */
router.get('/', function(req, res, next) {
	//res.send('respond with a resource');
	connection.query('SELECT * FROM user', function(err, rows, fields) {
		if (!err) {
			console.log('Getting all users', rows);
			res.json(rows);
		}
		else
			console.log('Error while getting all users', err);
	});
/*
	res.json([{
		id: 1,
		fname: "Henry",
		lname: "Niseau",
		username: "HenryN",
		date_of_birth: "1986-11-13"
	}, {
		id: 2,
		fname: "Marie",
		lname: "Debord",
		username: "Reveuse",
		date_of_birth: "1990-01-04"
	}, {
		id: 3,
		fname: "Yasine",
		lname: "Drissi",
		username: "Yaya75",
		date_of_birth: "1994-05-20"
	}]);*/
});

module.exports = router;
