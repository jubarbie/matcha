var config = require('../config');
var jwt = require('jsonwebtoken');
var UsersModel = require('../models/users_model');

var midd = {};

// Check if token is provided, user role
midd.hasRole = function (role) {

	return function (req, res, next) {

    var token = req.body.token || req.query.token || req.headers['x-access-token'];

		try {

      var decoded = jwt.verify(token, config.secret);

			UsersModel.getUserWithLogin(decoded.username, function(err, rows, fields) {
				if (!err && rows.length > 0 && rows[0].rights <= role) {
					req.logged_user = rows[0];
					next();
				} else {
					res.status(401).send();
				}
      });
		} catch (err) {
			res.status(401).send();
		}
	}

};

module.exports = midd;
