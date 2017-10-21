var express = require('express');
var router = express.Router();

const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var bcrypt = require('bcrypt');
var crypto = require('crypto');
const saltRounds = 10;
var jwt = require('jsonwebtoken');
var nodemailer = require('nodemailer');

var config = require('../config');
var UsersModel = require('../models/users_model');

/* GET users listing. */
router.post('/all_users', function(req, res, next) {

	var token = req.body.token || req.query.token || req.headers['x-access-token'];
	var username = req.body.user
		console.log("token recieved", token);

	if (token && username) {
		// verifies secret and checks exp
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
router.post('/user/:login', function(req, res, next) {

	var login = req.params.login;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && login) {
		jwt.verify(token, config.secret, function(err, decoded) {
				UsersModel.getUserWithLogin(login, function(err, rows, fields) {
					if (rows) {
						console.log("User ", rows[0]);
						res.json({"status":"success", "data":rows[0]});
					} else {
						res.json({"status":"error", "msg":"User " + login + " doesn't exists"});
					}
				});
		});
	} else {
		res.json({"status":"error", "msg":"Missing login"});
	}
});

/* GET user. */
router.get('/user/:login/emailverif', function(req, res, next) {

	var login = req.params.login;
	var token = req.query.r;

	if (login && token) {
		UsersModel.getTokenFromLogin(login, function(err, rows, fields) {
			if (rows) {
				console.log("User ", rows[0]);
				var activated = rows[0].activated;
				switch(activated) {
				    case token:
				        UsersModel.activatedUserWithLogin(login, function(err, rows, fields) {
							if (rows) { res.send('Email verified. You can now <a href="localhost:3000">login</a>'); }
							else { res.send('A problem occured, please try again'); }
						});
				        break;
				    case "activated":
				        res.send('Email already verified');
				        break;
				    default:
				        res.send('A problem occured, please try again');
				}

			} else {
				res.send('Invalid link');
			}
		});
	} else {
		res.send('Invalid link');
	}
});

/* REMOVE user. */
router.post('/delete_user', function(req, res, next) {

	var username = req.body.username;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && username) {
		jwt.verify(token, config.secret, function(err, decoded) {
			if (decoded.rights == 0) {
				UsersModel.deleteUser(username, function(err, rows, fields) {
					if (rows) {
						console.log("User ", rows);
						res.json({"status":"success"});
					} else {
						res.json({"status":"error", "msg":"User " + username + " doesn't exists"});
					}
				});
			} else {
				res.json({"status":"error", "msg": "unauthorize"});
			}
		});
	} else {
		res.json({"status":"error"});
	}
});

var buildUserFromRequest = function(req) {
	var user = {};
	user.login = req.body.username;
	user.email = req.body.email;
	user.fname = (req.body.fname) ? req.body.fname : "";
	user.lname = (req.body.lname) ? req.body.lname : "";
	user.gender = (req.body.gender) ? req.body.gender : "";
	user.int_in = (req.body.int_in) ? req.body.int_in : "";
	user.bio = (req.body.bio) ? req.body.bio : "";
	user.password = bcrypt.hashSync(req.body.password, saltRounds);
	user.activated = crypto.randomBytes(64).toString('hex');
	user.rights = 1;
	return user;
};

/* Insert new user with minimum infos */
router.post('/newfast', [
		check('username').exists(),
		check('email').exists().isEmail(),
		check('password').exists().isLength({ min: 5 }).matches(/\d/)
], (req, res, next) => {
	const errors = validationResult(req);
	if (!errors.isEmpty()) {
		res.status(422).json({"status":"error", "msg":errors});
	}
	UsersModel.getUserWithLogin(req.body.username, function(err, rows, fields) {
		if (rows[0]) {
			console.log(rows);
			res.json({"status":"error", "msg":"Login already used"});
		} else {
			var user = buildUserFromRequest(req);
			UsersModel.insertUser(user, function(err, rows, fields) {
				if (!err) {
					console.log('User inserted');
					nodemailer.createTestAccount((err, account) => {

					    // create reusable transporter object using the default SMTP transport
					    let transporter = nodemailer.createTransport({
					        host: 'smtp.ethereal.email',
					        port: 587,
					        secure: false, // true for 465, false for other ports
					        auth: {
					            user: account.user, // generated ethereal user
					            pass: account.pass  // generated ethereal password
					        }
					    });

					    // setup email data with unicode symbols
					    let mailOptions = {
					        from: '"DARKROOM" <noreply@darkroom.com>', // sender address
					        to: user.email, // list of receivers
					        subject: 'Welcome into the DARKROOM', // Subject line
					        html: '<b>Please verify you email by clicking on this link <a href="">localhost:3001/api/users/user/'+user.login+'/emailverif?r='+user.activated+'</a></b>' // html body
					    };

					    // send mail with defined transport object
					    transporter.sendMail(mailOptions, (error, info) => {
					        if (error) {
					            return console.log(error);
					        }
					        console.log('Message sent: %s', info.messageId);
					        // Preview only available when sending through an Ethereal account
					        console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));

					    });
					});
					res.json({"status":"success"});
				}
				else {
					console.log('Error while puting new user', err);
					res.json({"status":"error"});
				}
			});
		}
	});
});

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
			nodemailer.createTestAccount((err, account) => {

			    // create reusable transporter object using the default SMTP transport
			    let transporter = nodemailer.createTransport({
			        host: 'smtp.ethereal.email',
			        port: 587,
			        secure: false, // true for 465, false for other ports
			        auth: {
			            user: account.user, // generated ethereal user
			            pass: account.pass  // generated ethereal password
			        }
			    });

			    // setup email data with unicode symbols
			    let mailOptions = {
			        from: '"DARKROOM" <noreply@darkroom.com>', // sender address
			        to: user.email, // list of receivers
			        subject: 'Welcome to DARKROOM', // Subject line
			        html: '<b>Welcome!</b>' // html body
			    };

			    // send mail with defined transport object
			    transporter.sendMail(mailOptions, (error, info) => {
			        if (error) {
			            return console.log(error);
			        }
			        console.log('Message sent: %s', info.messageId);
			        // Preview only available when sending through an Ethereal account
			        console.log('Preview URL: %s', nodemailer.getTestMessageUrl(info));

			    });
			});
			res.json({"status":"success"});
		}
		else {
			console.log('Error while puting new user', err);
			res.json({"status":"error"});
		}
	});
});


module.exports = router;
