const config = require('../config');
const jwt = require('jsonwebtoken');
const UsersModel = require('../models/users_model');

// Check if token is provided, user role
exports.hasRole = (role) => {

    return (req, res, next) => {

        let token = (req.headers.authorization) ? req.headers.authorization.split(" ")[1] : "";

        jwt.verify(token, config.secret, (err, decoded) => {
          if (err) {
            console.log(err);
            res.status(401).send();
          } else {
            UsersModel.getUserWithUuid(decoded.id, (err2, rows, fields) => {
                if (!err2) {
                    if (rows.length > 0 && role >= rows[0].rights) {
                      req.logged_user = rows[0];
                      next();
                    } else {
                      res.status(401).send("Unauthorized");
                    }
                } else {
                    console.log(err2);
                    res.status(401).send();
                }
            });
          }
        });
  }
};
