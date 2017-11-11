var express = require('express');
var router = express.Router();
var jwt = require('jsonwebtoken');

var config = require('../config');
var TalkModel = require('../models/talk_model');
var UserModel = require('../models/users_model');

/* GET user. */
/* Todo not sending password */
router.post('/all_talks', function(req, res, next) {

	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token) {
		jwt.verify(token, config.secret, function(err, decoded) {
			var username = decoded.username
				TalkModel.getUserTalks(username, function(err, talks, fields) {
							var talkers = [];
							talkers = talks.map(function (talk) {
								 return (talk.username1 == username) ? talk.username2 : talk.username1;
							});
							console.log("talkers", talkers);
							res.json({"status":"success", "data":talkers});
						});
				});
	} else {
		res.json({"status":"error", "msg":"Missing login"});
	}
});

/* Talk user. */
router.post('/talk/:login', function(req, res, next) {

	var userTo = req.params.login;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && userTo) {
		jwt.verify(token, config.secret, function(err, decoded) {
			usersTab = [decoded.username, userTo].sort();
			TalkModel.getTalkFromUsers(usersTab[0], usersTab[1], function(err, talks, fields) {
					if (talks.length > 0) {
						console.log("talk found", talks);
						TalkModel.getTalkMessages(talks[0].id, function(err, mess, fields) {
							console.log("messages", mess);
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
	});
	} else {
		res.json({"status":"error"});
	}
});

/* New talk message */
router.post('/new_message', function(req, res, next) {

	var userTo = req.body.username;
	var message = req.body.message;
	var token = req.body.token || req.query.token || req.headers['x-access-token'];

	if (token && message && userTo) {
		jwt.verify(token, config.secret, function(err, decoded) {
			userFrom = decoded.username;
			usersTab = [userFrom, userTo].sort();
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
						console.log("from -> to", userFrom, userTo)
						res.json({"status":"error","msg":"No talks found with those 2 users"});
					}
			});
		});
	} else {
		res.json({"status":"error","msg":"Missing arguments"});
	}
});

module.exports = router;
