var config = require('../config');

var UsersModel = require('../models/users_model');
var LikesModel = require('../models/likes_model');
var TalkModel = require('../models/talk_model');
var ImageModel = require('../models/image_model');

var ctrl = {};

ctrl.getFullUser = (logged, login, callback) => {
	UsersModel.getFullDataUserWithLogin(logged.login, login, (err, rows, fields) => {
		if (!err && rows.length > 0) {
			var user = rows[0];
			user.has_talk = (user.talks > 0) ? true : false;
			user.photos = (user.photos) ? user.photos.split(',') : [];
			user.photos = user.photos.map(function (img) {
				return 'http://localhost:3001/' + config.upload_path + img;
			});
			user.match = "none";
			if (user.localisation) {
				user.localisation = JSON.parse(user.localisation);
			}
			user.tags = (user.tags) ? user.tags.split(',') : [];
			user.interested_in = (user.interested_in) ? user.interested_in.split(',') : [];
			ctrl.getMatchStatus(logged.login, login, (status) => {
				if (status) {
					user.match = status;
				}
				callback(user);
			})
		} else {
			callback(null);
		}
	});
};

ctrl.getConnectedUser = function (login, callback) {
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
				user.interested_in = (user.interested_in) ? user.interested_in.split(',') : [];
				user.tags = (user.tags) ? user.tags.split(',') : [];
				ImageModel.getImagesFromUserId(user.id, function(err, imgs, fields){
					if (!err && imgs.length > 0) {
						user.photos = imgs.map(function (img) {
							return [img.id, 'http://localhost:3001/' + config.upload_path + img.src];
						});
					}
					if (user.localisation) {
						user.localisation = JSON.parse(user.localisation);
					}
					callback(user);
				});
			});
		} else {
			callback(null);
		}
	});
};

ctrl.getRelevantUsers = (logged, callback) => {

  var gender = (logged.interested_in) ? logged.interested_in.split(',') : [];
  var int_in = (logged.gender) ? logged.gender : "M";

  UsersModel.getRelevantProfiles(logged.login, gender, int_in, function(err, rows, fields) {
    if (!err) {
      var users = rows.map(function (u) {
        u.has_talk = false;
				u.match = "match";
        u.photos = (u.photos) ? u.photos.split(",") : [];
				u.photos = u.photos.map(function (img) {
					return 'http://localhost:3001/' + config.upload_path + img;
				});
				u.tags = (u.tags) ? u.tags.split(',') : [];
        return u;
      });
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
