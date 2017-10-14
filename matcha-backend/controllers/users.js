var express = require('express');
var router = express.Router();

const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var jwt = require('jsonwebtoken'); 

var config = require('../config');
var UsersModel = require('../models/users_model');

/* GET users listing. */
router.post('/', function(req, res, next) {

	var token = req.body.token || req.query.token || req.headers['x-access-token'];
	var username = req.body.user
		console.log("token recieved", token);

	if (token && username) { 
		// verifies secret and checks exp
		var user = UsersModel.getUserWithLogin(username);
		jwt.verify(token, config.secret, function(err, decoded) {      
			if (err) {
				console.log('Error while verif');
				res.status(403);
				res.json({ success: false, message: 'Failed to authenticate token.' });    
			} else {

				UsersModel.getAllUsers(function(err, rows, fields) {
					if (!err) {
						console.log('Getting all users');
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
/* Todo not sending password */
router.post('/user/:user', function(req, res, next) {

	var login = req.params.user;

	if (login) {
		UsersModel.getUserWithLogin(login, function(err, rows, fields) {
			if (rows) {
				console.log("User ", rows[0]);
				res.json({"status":"success", "data":rows[0]}); 
			} else { 
				res.json({"status":"error", "msg":"Can't find user"}); 
			}
		}); 
	} else {
		res.json({"status":"error", "msg":"No login provided"});
	}
});

var buildUserFromRequest = function(req) {
	var user = {};
	user.login = req.body.username;
	user.email = req.body.email;
	user.fname = req.body.fname;
	user.lname = req.body.lname;
	user.gender = req.body.gender;
	user.int_in = req.body.int_in;
	user.bio = (req.body.bio) ? req.body.bio : "";
	user.password = bcrypt.hashSync(req.body.password, saltRounds);
	return user;
};

/* PUT new user */
router.post('/new', [
		check('username').exists(),
		check('email').exists().isEmail(),
		check('fname').exists().isLength({min:1, max:250}),
		check('lname').exists().isLength({min:1, max:250}),
		check('gender').exists().isIn(['M', 'F']),
		check('int_in').exists().matches('[FM]{1,2}'),
		check('password').exists().isLength({ min: 5 }).matches(/\d/)
], (req, res, next) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) {
		res.status(422).json({"status":"error", "msg":error});
	}
	var user = buildUserFromRequest(req);
	UsersModel.insertUser(user, function(err, rows, fields) {
		if (!err) {
			console.log('User inserted');
			res.json({"status":"success"});
		}
		else {
			console.log('Error while puting new user', err);
			res.json({"status":"error"});
		}
	});
});


module.exports = router;
