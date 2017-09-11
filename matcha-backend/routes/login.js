var express = require('express');
var router = express.Router();
const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var mysql = require('mysql');
var bcrypt = require('bcrypt');
const saltRounds = 10;


var connection = mysql.createConnection({
	host     : 'localhost',
	user     : 'jubarbie',
	password : '',
	database : 'matcha_db',
	socketPath: '/tmp/mysql.sock'
});

router.post('/', (req, res, next) => {
	var login = req.body.login;
	var pwd = req.body.password;
	
	connection.query('SELECT password FROM user WHERE login="'+login+'"', (err, rows, fields) => {
		if (!err) {
			if (bcrypt.compareSync(pwd, rows[0].password) == false) {
				res.json({"status":"error", "msg":"Le login ou le mot de passe n'est pas correct"});
			} else {
				req.session.user = login;
				console.log(req.session);
				res.json("OK");
			}
		} else {
			console.log('Error while getting user', err);
		}
	});
});

module.exports = router;
