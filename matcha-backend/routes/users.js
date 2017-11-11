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

var UserCtrl = require('../controllers/user_ctrl.js');

var UsersModel = require('../models/users_model');
var LikesModel = require('../models/likes_model');
var TalkModel = require('../models/talk_model');
var ImageModel = require('../models/image_model');


// Check if token is provided, user role
var isAuthorized = function (req, rights, next) {

	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	jwt.verify(token, config.secret, function(err, decoded) {
		if (!err) {
			UsersModel.getUserWithLogin(decoded.username, function(err, rows, fields) {
				if (!err && rows.length > 0 && rows[0].rights <= rights) {
					next (rows[0]);
				} else {
					next (null);
				}
			});
		} else {
			next(null);
		}
	});

};

/* GET users listing. */
router.post('/all_users', function(req, res, next) {

	isAuthorized(req, 0, function (logged) {
		if (logged) {
			UsersModel.getAllUsers(function(err, rows, fields) {
				if (!err) {
					console.log('Getting all users');
					var users = rows.map(function (user) {
						user.talks = [];
						user.photos = [];
						return user;
					});
					res.json({"status":"success", "data":users});
				}
				else
					res.json({"status":"error"});
			});
		} else {
			res.status(401).json({ "status":"error" });
		}
	});

});

/* GET users listing. */
router.post('/relevant_users', function(req, res, next) {

	isAuthorized(req, 1, function (logged) {
		if (logged) {
			UserCtrl.getRelevantUsers(logged, function (users) {
				if (users) {
					res.json({ "status":"success", "data": users });
				} else {
					res.json({ "status":"error", "msg": "A problem occur while fetching users" });
				}
			});
		} else {
			res.status(401).json({ "status":"error" });
		}
	});

});

/* GET user */
router.post('/user/:login', function(req, res, next) {

	var login = req.params.login;

	isAuthorized(req, 1, function (logged) {
		if (logged && login) {
			UserCtrl.getUser(login, function (user) {
				if (user) {
					res.json({"status":"success", "data":user});
				} else {
					res.json({"status":"error", "msg":"Error when fetching user"});
				}
			});
		} else {
			res.status(401).json({ "status":"error" });
		}
	});

});

/* Add photo to connected user */
router.post('/user/add_photo', function(req, res, next) {

	isAuthorized(req, 1, function (logged) {
		if (logged) {

		} else {
			res.status(401).json({ "status":"error" });
		}
	});
});

/* GET user */
router.post('/current_user/:login', function(req, res, next) {

	var login = req.params.login;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && login) {
		jwt.verify(token, config.secret, function(err, decoded) {
				UsersModel.getUserWithLogin(login, function(err, users, fields) {
					if (users) {
						console.log("User ", users[0]);
						user = users[0];
						LikesModel.getLikeFromUsers(decoded.username, login, function(err, likes, fields) {
							console.log("getting like", likes);
							usersTab = [decoded.username, login].sort();
							TalkModel.getTalkFromUsers(usersTab[0], usersTab[1], function(err, talks, fields) {
							userToSend = {};
							userToSend.login = user.login;
							userToSend.gender = user.gender;
							userToSend.bio = user.bio;
							userToSend.liked = (likes.length > 0) ? true : false;
							userToSend.has_talk = (talks.length > 0) ? true : false;
							userToSend.photos = [];
							ImageModel.getImagesFromUserId(userToSend.id, function(err, imgs, fields){
								if (!err && imgs.length > 0) {
									userToSend.photos = imgs;
								}
							});
							console.log("usertosend", userToSend);
							res.json({"status":"success", "data":userToSend});
							});
						});
					} else {
						res.json({"status":"error", "msg":"User " + login + " doesn't exists"});
					}
				});
		});
	} else {
		res.json({"status":"error", "msg":"Missing login"});
	}
});


/* Verify email */
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
							if (rows) { res.send('Email verified. You can now <a href="http://localhost:3000">login</a>'); }
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
			UsersModel.getUserWithLogin(decoded.username, function (err, rows, fields) {
				if (rows.length > 0 && rows[0].rights == 0) {
					UsersModel.deleteUser(username, function(err, results, fields) {
						if (results) {
							TalkModel.getUserTalks(username, function(err, talks, fields) {
								if (talks.lenth > 0) {
									talks.map(function (talk) {
										TalkModel.removeTalk(talk.id, null);
									});
								}
							});
							res.json({"status":"success"});
						} else {
							res.json({"status":"error", "msg":"User " + username + " doesn't exists"});
						}
					});
				} else {
					res.json({"status":"error", "msg": "unauthorize"});
				}
			});
		});
	} else {
		res.json({"status":"error"});
	}
});

/* Like or unlike user. */
router.post('/toggle_like', function(req, res, next) {

	var username = req.body.username;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && username) {
		jwt.verify(token, config.secret, function(err, decoded) {
				LikesModel.getLikeFromUsers(decoded.username, username, function(err, rows, fields) {
					if (rows[0]) {
						console.log("Already liked", rows);
						LikesModel.unLike(decoded.username, username, function(err, rows, fields) {
							if (rows) {
								res.json({"status":"success", "msg":"unliked"});
							} else {
								console.log("error when unliking");
								res.json({"status":"error"});
							}
						});
					} else {
						console.log("Not liked yet", rows);
						LikesModel.like(decoded.username, username, function(err, rows, fields) {
							if (rows) {
								res.json({"status":"success", "msg":"liked"});
							} else {
								console.log("error when liking");
								res.json({"status":"error"});
							}
						});
					}
				});
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
			var now = Date.now();
			UsersModel.insertUser(user, now, function(err, rows, fields) {
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
		res.status(422).json({"status":"error", "msg":errors});
	}
	var user = buildUserFromRequest(req);
	var now = Date.now();
	UsersModel.insertUser(user, now, function(err, rows, fields) {
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

/* Update user infos */
router.post('/update', [
		check('email').exists().isEmail(),
		check('fname').exists().isLength({min:1, max:250}),
		check('lname').exists().isLength({min:1, max:250}),
		check('gender').exists().isIn(['M', 'F']),
		check('int_in').exists().matches('[FM]{1,2}')
], (req, res, next) => {

	const errors = validationResult(req);
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token) {
		jwt.verify(token, config.secret, function(err, decoded) {
			if (err || !errors.isEmpty()) {
				res.status(422).json({"status":"error", "msg":"invalid form"});
			} else {
				var infos = {};
				infos.email = req.body.email;
				infos.fname = req.body.fname;
				infos.lname = req.body.lname;
				infos.gender = req.body.gender;
				infos.int_in = req.body.int_in;
				infos.bio = (req.body.bio) ? req.body.bio : "";

				UsersModel.updateInfos(decoded.username, infos, function (err, rows, fields) {
					if (rows && !err) {
						console.log('User modified', rows);
						res.json({"status":"success"});
					} else {
						console.log('Error while puting new user', err);
						res.json({"status":"error"});
					}
				});
			}
		});
	}
});

/* Like or unlike user. */
router.post('/save_loc', function(req, res, next) {

	var lat = req.body.lat;
	var lon = req.body.lon;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && lat && lon) {
		var loc = {};
		loc.lon = lon;
		loc.lat = lat;
		console.log("saving loc", loc);
		jwt.verify(token, config.secret, function(err, decoded) {
				UsersModel.updateLocation(decoded.username, JSON.stringify(loc), function (err, rows, fields) {
					if (!err) {
						res.json({"status":"success"});
					} else {
						console.log("error", err);
						res.json({"status":"error"});
					}
				});
		});
	} else {
		res.json({"status":"error"});
	}
});

module.exports = router;
