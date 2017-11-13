var express = require('express');
var apiRoutes = express.Router();
const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var config = require('../config');
var jwt = require('jsonwebtoken');

var UserCtrl = require('../controllers/user_ctrl.js');

var ImageModel = require('../models/image_model');

apiRoutes.post('/', (req, res, next) => {

	var login = req.body.login;
	var pwd = req.body.password;

	UserCtrl.getConnectedUser(login, function (user) {
		if (user) {
			if (bcrypt.compareSync(pwd, user.password) == false) {
				res.json({"status":"error", "msg":"Incorrect login or password"});
			} else if (user.activated != "activated") {
				res.json({"status":"error", "msg":"You must activate your email first"});
			} else {
				var token = jwt.sign({"username": user.login}, config.secret, {
					expiresIn: "1 day"
				});
				res.json({"status":"success", "token":token, "data":user});
			}
		} else {
			res.json({"status":"error", "msg":"Incorrect login or password"});
		}
	});
});

module.exports = apiRoutes;
