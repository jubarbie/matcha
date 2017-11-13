var config = require('../config');

var UsersModel = require('../models/users_model');
var LikesModel = require('../models/likes_model');
var TalkModel = require('../models/talk_model');
var ImageModel = require('../models/image_model');

var ctrl = {};

ctrl.getUser = function (login, callback) {
	UsersModel.getUserWithLogin(login, function(err, rows, fields) {
		if (!err && rows.length > 0) {
			var user = rows[0];
			TalkModel.getUserTalks(login, function(err, talks, fields) {
				var talkers = [];
				talkers = talks.map(function (talk) {
					 return (talk.username1 == login) ? talk.username2 : talk.username1;
				});
				user.talks = talkers;
				user.photos = [];
				ImageModel.getImagesFromUserId(user.id, function(err, imgs, fields){
					if (!err && imgs.length > 0) {
						user.photos = imgs.map(function (img) {
							return img.src;
						});
					}
					if (loc = user.localisation) {
						user.localisation = JSON.parse(loc);
					}
					this.getMatchStatus();
					callback(user);
				});
			});
		} else {
			callback(null);
		}
	});
};

ctrl.getRelevantUsers = function (user, callback) {

  var gender = (user.int_in) ? user.int_in : "M";
  var int_in = (user.gender) ? user.gender : "M";

  UsersModel.getRelevantProfiles(gender, int_in, function(err, rows, fields) {
    if (!err) {
      var users = rows.map(function (u) {
        u.talks = [];
        u.photos = (u.photos) ? u.photos.split(",") : [];
        return u;
      });
      console.log(users);
      callback(users);
		} else {
			callback(null);
		}
	});
};

ctrl.getMatchStatus = function (userFrom, userTo, cb) {

	var matchStatus = "none";

	LikesModel.getLikeBetweenUsers(userFrom, userTo, function (err, row1s, fields) {
		if (!err && row1s.length > 0) {
			matchStatus = "to";
		}
		LikesModel.getLikeBetweenUsers(userTo, userFrom, function (err, row2s, fields) {
			if (!err && row2s.length > 0) {
				matchStatus = (matchStatus == "to") ? "match" : "from";
			}
			cb(matchStatus);
		});
	});
};

module.exports = ctrl;
