const express = require('express');
const apiRoutes = express.Router();
const {
    check,
    validationResult
} = require('express-validator/check');
const {
    matchedData
} = require('express-validator/filter');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const saltRounds = 10;
const config = require('../config');
const jwt = require('jsonwebtoken');
const Mailer = require('../middlewares/mailer');
const UserCtrl = require('../controllers/user_ctrl.js');
const UsersModel = require('../models/users_model.js');
const ImageModel = require('../models/image_model');
const uuidv1 = require('uuid/v1');

apiRoutes.post('/', (req, res, next) => {

    var login = req.body.login;
    var pwd = req.body.password;

    UserCtrl.getConnectedUser(login, function(user) {
        if (user) {
            if (bcrypt.compareSync(pwd, user.password) == false) {
                res.json({
                    "status": "error",
                    "msg": "Incorrect login or password"
                });
            } else if (user.activated != "activated" && user.activated != "incomplete" && user.activated != "resetpwd") {
                res.json({
                    "status": "error",
                    "msg": "You must activate your email first"
                });
            } else {
                var uuid = uuidv1();
                var token = jwt.sign({
                    "id": uuid
                }, config.secret, {
                    expiresIn: "15 min"
                });
                var now = Date.now();
                UsersModel.updateConnectionDate(user.id, now, uuid, (err, rows, fields) => {
                    console.log(user);
                    res.json({
                        "status": "success",
                        "token": token,
                        "data": user
                    });
                });
            }
        } else {
            res.json({
                "status": "error",
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
    user.gender = (req.body.gender) ? req.body.gender : "";
    user.int_in = (req.body.int_in) ? req.body.int_in : "";
    user.bio = (req.body.bio) ? req.body.bio : "";
    user.password = bcrypt.hashSync(req.body.password, saltRounds);
    user.activated = crypto.randomBytes(64).toString('hex');
    user.rights = 1;
    return user;
};

/* Insert new user with minimum infos */
apiRoutes.post('/newfast', [
    check('username').exists(),
    check('fname').exists(),
    check('lname').exists(),
    check('email').exists().isEmail(),
    check('password').exists().isLength({
        min: 5
    }).matches(/\d/)
], (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        res.status(422).json({
            "status": "error",
            "msg": errors
        });
    }
    UsersModel.getUserWithLogin(req.body.username, function(err, rows, fields) {
        if (rows[0]) {
            res.json({
                "status": "error",
                "msg": "Login already used"
            });
        } else {
            var user = buildUserFromRequest(req);
            var now = Date.now();
            UsersModel.insertUser(user, now, function(err, rows, fields) {
                if (!err) {
                    Mailer.sendVerifEmail(user.email, user.login, user.activated);
                    res.json({
                        "status": "success"
                    });
                } else {
                    console.log('Error insert new user', err);
                    res.json({
                        "status": "error"
                    });
                }
            });
        }
    });
});

/* Send verification email */
apiRoutes.post('/send_email_verification', (req, res, next) => {

    var username = req.body.username;

    UsersModel.getUserWithLogin(username, function(err, rows, fields) {
        if (err || !rows) {
            res.json({
                "status": "error",
                "msg": "User doesn't exist"
            });
        } else {
            var user = rows[0];
            Mailer.sendVerifEmail(user.email, user.login, user.activated);
            res.json({
                "status": "success"
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
                "status": "error",
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
                        "status": "success"
                    });
                } else {
                    console.log(err);
                    res.json({
                        "status": "error"
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
                                res.send('Email verified. You can now <a href="' + config.home_url + '">login</a>');
                            } else {
                                res.send('A problem occured, please try again');
                            }
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

module.exports = apiRoutes;