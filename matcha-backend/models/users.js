var express = require('express');
var router = express.Router();
const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var mysql = require('mysql');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var jwt = require('jsonwebtoken'); 
var config = require('../config');

var connection = mysql.createConnection(config.database);


/* GET users listing. */
router.post('/', function(req, res, next) {

	var token = req.body.token || req.query.token || req.headers['x-access-token'];
	console.log("token recieved", token);

	if (token) {

		// verifies secret and checks exp
		jwt.verify(token, config.secret, function(err, decoded) {      
			if (err) {
				console.log('Error while verif');
				res.json({ success: false, message: 'Failed to authenticate token.' });    
			} else {

				connection.query('SELECT * FROM user', function(err, rows, fields) {
					if (!err) {
						console.log('Getting all users', rows);
						res.json(rows);
					}
					else
						console.log('Error while getting all users', err);
				});
			}
		});

	} else {

		res.status(403).send({ 
			success: false, 
			message: 'No token provided.' 
		});

	}
});

/* GET user. */
router.get('/:id', function(req, res, next) {

	var id = req.params.id;

	connection.query('SELECT * FROM user WHERE id='+id, function(err, rows, fields) {
		if (!err) {
			console.log('Getting user with id', rows);
			res.json(rows);
		}
		else
			console.log('Error while getting all users', err);
	});

});

/* PUT new user */
router.put('/new', [
	check('login').exists(),
	check('email').exists().isEmail(),
	check('fname').exists().isLength({min:1, max:250}),
	check('lname').exists().isLength({min:1, max:250}),
	check('gender').exists().isIn(['M', 'F']),
	check('int_in').exists().matches('[FM]{1,2}'),
	check('password').exists().isLength({ min: 5 }).matches(/\d/)
], (req, res, next) => {
	try {
		validationResult(req).throw();
		var login = req.body.login;
		var email = req.body.email;
		var fname = req.body.fname;
		var lname = req.body.lname;
		var gender = req.body.gender;
		var int_in = req.body.int_in;
		var bio = (req.body.bio) ? req.body.bio : "";
		var password = bcrypt.hashSync(req.body.password, saltRounds);
		connection.query('INSERT INTO user (login, email, fname, lname, password, gender, interested_in, bio) VALUES ("'+login+'","'+email+'","'+fname+'", "'+lname+'","'+password+'","'+gender+'","'+int_in+'","'+bio+'")', function(err, rows, fields) {
			if (!err) {
				console.log('User inserted');
				res.json({"status":"OK"});
			}
			else
				console.log('Error while puting new user', err);
		});
	} catch (err) {
		res.status(422).json({"status":"error", "msg":err.mapped()});
	}


});


module.exports = router;
