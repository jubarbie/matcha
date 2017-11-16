var express = require('express');
var router = express.Router();

var UsersModel = require('../models/users_model');
var TalkModel = require('../models/talk_model');


/* GET users listing. */
router.post('/all_users', (req, res, next) => {

	UsersModel.getAllUsers( (err, rows, fields) => {
		if (!err) {
			var users = rows.map((user) => {
				user.talks = [];
				user.photos = [];
				user.localisation = [];
				return user;
			});
			console.log('Getting all users', users);
			res.json({"status":"success", "data":users});
		}
		else
			res.json({"status":"error"});
	});

});

/* REMOVE user. */
router.post('/delete_user', function(req, res, next) {

	var username = req.body.username;

  if (username) {
    UsersModel.deleteUser(username, function(err, results, fields) {
      if (results) {
        TalkModel.getUserTalks(username, function(err, talks, fields) {
					console.log("getting talks", talks);
          if (talks.length > 0) {
						console.log("talks", talks);
            talks.map(function (talk) {
              TalkModel.removeTalk(talk.id);
            });
          }
        });
        res.json({"status":"success"});
      } else {
        res.json({"status":"error", "msg":"User " + username + " doesn't exists"});
      }
    });
  } else {
    res.json({"status":"error", "msg": "unauthorize"});
  }

});


module.exports = router;
