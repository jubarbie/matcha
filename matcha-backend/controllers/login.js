var express = require('express');
var apiRoutes = express.Router();
const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var config = require('../config');
var jwt = require('jsonwebtoken');

var UsersModel = require('../models/users_model');

apiRoutes.post('/', (req, res, next) => {

	var login = req.body.login;
	var pwd = req.body.password;

	UsersModel.getUserWithLogin(login, (err, rows, fields) => {
		if (!err) {
			var user = rows[0];
			if (user == undefined || bcrypt.compareSync(pwd, user.password) == false) {
				console.log("Mauvais mot de passe");
				res.json({"status":"error", "msg":"Incorrect login or password"});
			} else if (user.activated != "activated") {
				res.json({"status":"error", "msg":"You must activate your email"});
			} else {
				var token = jwt.sign({"username": user.login}, config.secret, {
					expiresIn: "1 day"
				});
				user.talks = [];
				user.photos = ["http://popnhop.com/wp-content/uploads/2015/01/bigstock-LOS-ANGELES-NOVEMBER-Joc-58406525-400x242.jpg?a0519e"];
				console.log("Token create", token);
				console.log("User sent", user);
				res.json({"status":"success", "token":token, "data":user});
			}
		} else {
			console.log('Error while getting user', err);
		}
	});
});

module.exports = apiRoutes;
