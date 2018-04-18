const express = require('express');
const apiRoutes = express.Router();
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const saltRounds = 10;
const config = require('../config');
const jwt = require('jsonwebtoken');
const Mailer = require('../middlewares/mailer');
const validation = require('../middlewares/validation.js');
const UserCtrl = require('../controllers/user_ctrl.js');
const UsersModel = require('../models/users_model.js');
const ImageModel = require('../models/image_model');
const uuidv1 = require('uuid/v1');

apiRoutes.post('/token', (req, res, next) => {

    var login = req.body.login;
    var pwd = req.body.password;

    UserCtrl.getConnectedUser(login, function(user) {
        if (user) {
            if (bcrypt.compareSync(pwd, user.password) == false) {
                console.log("Wrong pwd")
                res.json({
                    "status": false,
                    "msg": "Incorrect login or password"
                });
            } else if (user.activated != "activated" && user.activated != "incomplete" && user.activated != "resetpwd") {
                console.log("Not activated")
                res.json({
                    "status": false,
                    "msg": "You must activate your email first"
                });
            } else {
                var uuid = uuidv1();
                var token = jwt.sign({
                    "id": uuid
                }, config.secret, {
                    expiresIn: "120 min"
                });
                var now = Date.now();
                delete user.password;
                UsersModel.updateConnectionDate(user.id, now, uuid, (err, rows, fields) => {
                    res.json({
                        "status": true,
                        "token": token,
                        "data": user
                    });
                });
            }
        } else {
            console.log("User does not exists");
            res.json({
                "status": false,
                "msg": "Incorrect login or password"
            });
        }
    });
});

var buildUserFromRequest = function(req) {
    var user = {};
    user.login = req.body.username;
    user.email = req.body.email;
    user.fname = req.body.fname;
    user.lname = req.body.lname;
    user.password = bcrypt.hashSync(req.body.password, saltRounds);
    user.activated = crypto.randomBytes(64).toString('hex');
    user.rights = 1;
    user.bio = "";
    return user;
};

/* Insert new user */
apiRoutes.post('/new', (req, res, next) => {

    const valid = validation.validateNewUserInfos(req);

    if (!valid.valid) {
        res.json({
            "status": false,
            "msg": valid.errors
        });
    } else {
        UsersModel.getUserWithLogin(req.body.username, function(err, rows, fields) {
            if (rows.length > 0) {
                res.json({
                    "status": false,
                    "msg": "Login already used"
                });
            } else {
                var user = buildUserFromRequest(req);
                var now = Date.now();
                UsersModel.insertUser(user, now, function(err, rows, fields) {
                    if (!err) {
                        var url = Mailer.sendVerifEmail(user.email, user.login, user.activated);
                        res.json({
                            "status": true,
                            "msg": url
                        });
                    } else {
                        res.json({
                            "status": false
                        });
                    }
                });
            }
        });
    }
});

/* Send verification email */
apiRoutes.post('/send_email_verification', (req, res, next) => {

    var username = req.body.username;

    UsersModel.getUserWithLogin(username, function(err, rows, fields) {
        if (err || !rows) {
            res.json({
                "status": false,
                "msg": "User doesn't exist"
            });
        } else {
            var user = rows[0];
            Mailer.sendVerifEmail(user.email, user.login, user.activated);
            res.json({
                "status": true
            });
        }
    });
});

/* Insert new user with minimum infos */
apiRoutes.post('/reset_password', (req, res, next) => {

    var username = req.body.username;
    var email = req.body.email;

    UsersModel.getUserWithLoginAndEmail(username, email, (err, rows, fields) => {
        if (err || rows.length == 0) {
            res.json({
                "status": false,
                "msg": "No user with this login and email address"
            });
        } else {
            var user = rows[0];
            var pwd = crypto.randomBytes(4).toString('hex');
            var pwdCrypt = bcrypt.hashSync(pwd, saltRounds);
            var activatedStatus = "resetpwd";
            UsersModel.updatePassword(user.login, pwdCrypt, activatedStatus, function(err, rows, fields) {
                if (!err) {
                    Mailer.sendResetPasswordEmail(user.email, user.login, pwd);
                    res.json({
                        "status": true
                    });
                } else {
                    res.json({
                        "status": false
                    });
                }
            });
        }
    });
});

/* Verify email */
apiRoutes.get('/emailverif/:login', (req, res, next) => {

    const login = req.params.login;
    const token = req.query.r;

    if (login && token) {
        UsersModel.getTokenFromLogin(login, function(err, rows, fields) {
            if (rows) {
                var activated = rows[0].activated;
                switch (activated) {
                    case token:
                        UsersModel.activateUserWithLogin(login, "incomplete", (err, rows, fields) => {
                            if (rows) {
                                res.send(getTemplate('Email verified. You can now <a href="' + config.home_url + '">login</a>'));
                            } else {
                                res.send(getTemplate('A problem occured, please try again'));
                            }
                        });
                        break;
                    case "activated":
                        res.send(getTemplate('Email already verified. <a href="' + config.home_url + '">login</a>'));
                        break;
                    case "incomplete":
                        res.send(getTemplate('Email already verified. <a href="' + config.home_url + '">login</a>'));
                        break;
                    default:
                        res.send(getTemplate('A problem occured, please try again'));
                }

            } else {
                res.send(getTemplate('Invalid link'));
            }
        });
    } else {
        res.send(getTemplate('Invalid link'));
    }
});

function getTemplate(msg) {
    var tmp =
        "<html> \
    <head> \
      <style> \
        html, body { \
          width: 100%; height: 100%; background: #252525; text-align: center; color: white; display: flex; align-items: center; justify-content: center; font-size: 1.2em; \
        } \
        a { color: #1EAEDB; text-decoration: none}\
      </style> \
    </head> \
    <body> \
     <div>" + msg + "</div> \
    </body> \
    </html> "
    return tmp;
}

module.exports = apiRoutes;