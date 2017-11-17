var express = require('express');
var router = express.Router();
const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var bcrypt = require('bcrypt');
var crypto = require('crypto');
const saltRounds = 10;
var config = require('../config');
var UserCtrl = require('../controllers/user_ctrl.js');
var UsersModel = require('../models/users_model');
var LikesModel = require('../models/likes_model');
var TalkModel = require('../models/talk_model');
var ImageModel = require('../models/image_model');


/* GET users listing. */
router.post('/relevant_users', (req, res, next) => {

	var logged = req.logged_user;

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

/* GET user */
router.post('/user/:login', (req, res, next) => {

	var login = req.params.login;
	var logged = req.logged_user;

	if (logged && login) {
		UserCtrl.getFullUser(logged, login, function (user) {
			if (user) {
				console.log(user);
				res.json({"status":"success", "data":user});
			} else {
				res.json({"status":"error", "msg":"Error when fetching user"});
			}
		});
	} else {
		res.status(401).json({ "status":"error" });
	}


});

/* Add photo to connected user */
router.post('/user/add_photo', (req, res, next) => {

	//TODO

});

/* GET user */
router.post('/user/:login', (req, res, next) => {

	var login = req.params.login;
	var logged = req.logged_user;

	if (logged && login) {
		UserCtrl.getFullUser(logged, login, function (user) {
			if (user) {
				usersTab = [logged.login, login].sort();
				UserCtrl.getMatchStatus(logged.login, login, function (status) {
					user.match = status;
					user.has_talk = (user.talks > 0) ? true : false;
					res.json({"status":"success", "data":user});
				});
			} else {
				res.json({"status":"error", "msg":"User " + login + " doesn't exists"});
			}
		});
	} else {
		res.json({"status":"error", "msg":"Missing login"});
	}

});

/* GET user */
router.post('/connected_user', (req, res, next) => {

	var logged = req.logged_user;

	if (logged) {
		UserCtrl.getConnectedUser(logged.login, function (user) {
			if (user) {
					res.json({"status":"success", "data":user});
			} else {
				res.json({"status":"error", "msg":"User " + login + " doesn't exists"});
			}
		});
	} else {
		res.json({"status":"error", "msg":"Missing login"});
	}

});


/* Verify email */
router.get('/user/:login/emailverif', (req, res, next) => {

	var login = req.params.login;
	var token = req.query.r;

	if (login && token) {
		UsersModel.getTokenFromLogin(login, function(err, rows, fields) {
			if (rows) {
				var activated = rows[0].activated;
				switch(activated) {
				    case token:
				        UsersModel.activateUserWithLogin(login, "incomplete", (err, rows, fields) => {
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


/* Like or unlike user. */
router.post('/toggle_like', (req, res, next) => {

	var username = req.body.username;
	var logged = req.logged_user;

	if (logged && username) {
		LikesModel.getLikeBetweenUsers(logged.login, username, function(err, rows, fields) {
			if (rows[0]) {
				LikesModel.unLike(logged.login, username, function(err, rows, fields) {
					if (rows) {
						UserCtrl.getMatchStatus(logged.login, username, function (status) {
							res.json({"status":"success", "data":status});
						})
					} else {
						res.json({"status":"error"});
					}
				});
			} else {
				LikesModel.like(logged.login, username, function(err, rows, fields) {
					if (rows) {
						UserCtrl.getMatchStatus(logged.login, username, function (status) {
							res.json({"status":"success", "data":status});
						})
					} else {
						res.json({"status":"error"});
					}
				});
			}
		});
	} else {
		res.json({"status":"error"});
	}
});

/* Update user infos */
router.post('/update', [
		check('email').exists().isEmail(),
		check('fname').exists().isLength({min:1, max:250}),
		check('lname').exists().isLength({min:1, max:250}),
], (req, res, next) => {

	const errors = validationResult(req);
	var logged = req.logged_user;

	if (logged) {
		if (!errors.isEmpty()) {
			res.json({"status":"error", "msg":"invalid form"});
		} else {
			var infos = {};
			infos.email = req.body.email;
			infos.fname = req.body.fname;
			infos.lname = req.body.lname;
			infos.bio = (req.body.bio) ? req.body.bio : "";

			UsersModel.updateInfos(logged.login, infos, function (err, rows, fields) {
				if (rows && !err) {
					res.json({"status":"success"});
				} else {
					res.json({"status":"error"});
				}
			});
		}
	}
});

/* Update specific field */
router.post('/update_field', [
		check('field').exists().isIn(['gender', 'interested_id']),
		check('value').exists()
], (req, res, next) => {

	const errors = validationResult(req);
	var logged = req.logged_user;

	if (logged) {
		if (!errors.isEmpty()) {
			res.json({"status":"error", "msg":"invalid form"});
		} else {
			var value = req.body.value;
			UsersModel.updateField(logged.login, field, value, (err, rows, fields) => {
				if (rows && !err) {
					UserCtrl.getConnectedUser(logged.login, function (user) {
						if (user) {
							res.json({"status":"success", "data":user});
						} else {
							res.json({"status":"error"});
						}
					});
				} else {
					res.json({"status":"error"});
				}
			});
		}
	}
});

/* Update user password */
router.post('/change_password', [
		check('oldPwd').exists(),
		check('newPwd').exists().isLength({ min: 5 }).matches(/\d/)
], (req, res, next) => {

	const errors = validationResult(req);
	var logged = req.logged_user;
	var oldPwd = req.body.oldPwd;
	var newPwd = req.body.newPwd;

	if (logged && oldPwd && newPwd) {
		if (!errors.isEmpty()) {
			res.json({"status":"error", "msg":"invalid form"});
		} else {
			UsersModel.getUserWithLogin(logged.login, (err, users, fields) => {
				if (!err && users.length > 0) {
					var user = users[0];
					if (bcrypt.compareSync(oldPwd, user.password) == false) {
						res.json({"status":"error", "msg":"Incorrect password"});
					} else {
						var password = bcrypt.hashSync(newPwd, saltRounds);
						UsersModel.updatePassword(logged.login, password, "activated",  (err, rows, fields) => {
							if (rows && !err) {
								res.json({"status":"success"});
							} else {
								res.json({"status":"error"});
							}
						});
					}
				} else {
					res.json({"status":"error"});
				}
			})

		}
	}
});

/* Like or unlike user. */
router.post('/save_loc', (req, res, next) => {

	var lat = req.body.lat;
	var lon = req.body.lon;
	var logged = req.logged_user;

	if (logged && lat && lon) {
		var loc = {};
		loc.lon = lon;
		loc.lat = lat;
		UsersModel.updateLocation(logged.login, JSON.stringify(loc), (err, rows, fields) => {
			if (!err) {
				res.json({"status":"success"});
			} else {
				console.log("error", err);
				res.json({"status":"error"});
			}
		});
	} else {
		res.json({"status":"error"});
	}

});

module.exports = router;
