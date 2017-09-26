var express = require('express');
var apiRoutes = express.Router();
const { check, validationResult } = require('express-validator/check');
const { matchedData } = require('express-validator/filter');
var mysql = require('mysql');
var bcrypt = require('bcrypt');
const saltRounds = 10;
var config = require('../config');
var jwt = require('jsonwebtoken'); 

var connection = mysql.createConnection(config.database);

apiRoutes.post('/', (req, res, next) => {
	
	var login = req.body.login;
	var pwd = req.body.password;
	
	connection.query('SELECT * FROM user WHERE login="'+login+'"', (err, rows, fields) => {
		if (!err) {
			console.log(rows);
			var user = rows[0];
			if (user == undefined || bcrypt.compareSync(pwd, user.password) == false) {
				console.log("Mauvais mot de passe");
				res.json({"status":"error", "msg":"Le login ou le mot de passe n'est pas correct"});
			} else {
				var token = jwt.sign({"user": login}, config.secret, {
					expiresIn: "1 day"
				});
				console.log("Token create", token);
				res.json({"status":"success", "token":token, "data":user});
			}
		} else {
			console.log('Error while getting user', err);
		}
	});
});

module.exports = apiRoutes;
