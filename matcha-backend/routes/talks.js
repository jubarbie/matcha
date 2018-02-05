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
            talks.map(function(talk) {
                talk.messages = [];
                talk.new_message = "";
                return talk;
            });
            res.json({
                "status": "success",
                "data": talks
            });
        });
    } else {
        res.json({
            "status": "error",
            "msg": "Missing login"
        });
    }
});

/* Talk user. */
router.post('/talk/:login', function(req, res, next) {

    var userTo = req.params.login;
    var updateLast = req.body.update;
    var logged = req.logged_user;

    if (logged && userTo) {

        var usersTab = [logged.login, userTo].sort();
        var userNb = "user" + (usersTab.indexOf(logged.login) + 1) + "_last";
        var now = Date.now();

        TalkModel.getTalkFromUsers(usersTab[0], usersTab[1], function(err, talks, fields) {
            if (talks.length > 0) {
                if (updateLast) TalkModel.updateLast(talks[0].id, userNb, now);
                TalkModel.getTalkMessages(talks[0].id, userNb, function(err, mess, fields) {
                    TalkModel.getUnseenMessagesForTalk(talks[0].id, userNb, function(err, num, fields) {
                        res.json({
                            "status": "success",
                            "data": {
                                "username": userTo,
                                "messages": mess,
                                "unread": num[0].unread,
                                "new_message": ""
                            }
                        });
                    });
                });

            } else {
                UserModel.getUserWithLogin(userTo, function(err, rows, fields) {
                    if (rows.length > 0) {
                        TalkModel.newTalk(usersTab[0], usersTab[1], now, function(err, rows, fields) {
                            res.json({
                                "status": "success",
                                "data": []
                            });
                        });
                    } else {
                        res.json({
                            "status": "error",
                            "msg": "Unknown user"
                        });
                    }
                });
            }
        });

    } else {
        res.json({
            "status": "error"
        });
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
                var now = Date.now();
                TalkModel.newMessage(talkId, message, userFrom, now, function(err, rows, fields) {
                    TalkModel.getTalkMessages(talkId, function(err, mess, fields) {
                        if (mess.length > 0) {
                            res.json({
                                "status": "success",
                                "data": mess
                            });
                        } else {
                            res.json({
                                "status": "error",
                                "msg": "Problem to get messages"
                            });
                        }
                    });
                });
            } else {
                res.json({
                    "status": "error",
                    "msg": "No talks found with those 2 users"
                });
            }
        });
    } else {
        res.json({
            "status": "error",
            "msg": "Missing arguments"
        });
    }
});

module.exports = router;