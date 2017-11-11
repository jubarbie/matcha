var express = require('express');
var router = express.Router();
var jwt = require('jsonwebtoken');

var config = require('../config');
var TalkModel = require('../models/talk_model');
var UserModel = require('../models/users_model');

/* Getting all connected user talks */
router.post('/all_talks', function(req, res, next) {

	var logged = req.logged_user;

	if (logged) {
		TalkModel.getUserTalks(logged.login, function(err, talks, fields) {
			var talkers = [];
			talkers = talks.map(function (talk) {
				 return (talk.username1 == logged.login) ? talk.username2 : talk.username1;
			});
			console.log("talkers", talkers);
			res.json({"status":"success", "data":talkers});
		});
	} else {
		res.json({"status":"error", "msg":"Missing login"});
	}
});

/* Talk user. */
router.post('/talk/:login', function(req, res, next) {

	var userTo = req.params.login;
	var logged = req.logged_user;

	if (logged && userTo) {

		var usersTab = [logged.login, userTo].sort();

		TalkModel.getTalkFromUsers(usersTab[0], usersTab[1], function(err, talks, fields) {
			if (talks.length > 0) {
				TalkModel.getTalkMessages(talks[0].id, function(err, mess, fields) {
					res.json({ "status":"success", "data":mess });
				});
			} else {
				UserModel.getUserWithLogin(userTo, function(err, rows, fields) {
					if (rows.length > 0) {
						TalkModel.newTalk(usersTab[0], usersTab[1], function(err, rows, fields) {
							res.json({ "status":"success", "data":[]} );
						});
					} else {
						res.json({"status":"error","msg":"Unknown user"});
					}
				});
			}
		});
		
	} else {
		res.json({"status":"error"});
	}
});

/* New talk message */
router.post('/new_message', function(req, res, next) {

	var userTo = req.body.username;
	var message = req.body.message;
	var logged = req.logged_user

	if (logged && message && userTo) {
		var userFrom = logged.login;
		var usersTab = [userFrom, userTo].sort();
		TalkModel.getTalkFromUsers(usersTab[0], usersTab[1], function(err, talks, fields) {
			if (talks.length > 0) {
				talkId = talks[0].id;
				now = Date.now();
				TalkModel.newMessage(talkId, message, userFrom, now, function(err, rows, fields) {
          TalkModel.getTalkMessages(talkId, function (err, mess, fields) {
            if (mess.length > 0) {
              res.json({"status":"success", "data":mess});
            } else {
              res.json({"status":"error", "msg":"Problem to get messages"});
            }
          });
				});
			} else {
				res.json({"status":"error","msg":"No talks found with those 2 users"});
			}
		});
	} else {
		res.json({"status":"error","msg":"Missing arguments"});
	}
});

module.exports = router;
