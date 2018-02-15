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
				return config.root_url + config.upload_path + img;
			});
			user.match = "none";
			if (user.localisation && logged.localisation) {
				user.distance = getDistance(JSON.parse(logged.localisation), JSON.parse(user.localisation))
			}
			user.localisation = "secret information";
			user.tags = (user.tags) ? user.tags.split(',') : [];
			user.interested_in = (user.interested_in) ? user.interested_in.split(',') : [];
			user.visitor = (user.visitor != null) ? true : false;
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

function getDistance(pos_from, pos_to) {

	let R = 6371; // Radius of the earth in km
  let dLat = deg2rad(pos_to.lat - pos_from.lat);  // deg2rad below
  let dLon = deg2rad(pos_to.lon - pos_from.lon);
  let a =
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(deg2rad(pos_from.lat)) * Math.cos(deg2rad(pos_to.lat)) *
    Math.sin(dLon/2) * Math.sin(dLon/2)
    ;
  let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  let d = R * c; // Distance in km

	return d;
}

function deg2rad(deg) {
  return deg * (Math.PI/180)
}

ctrl.getConnectedUser = function (login, callback) {
	UsersModel.getUserWithLogin(login, function(err, rows, fields) {
		if (!err && rows.length > 0) {
			var user = rows[0];
			TalkModel.getUserTalks(login, function(err, talks, fields) {
				talks.map(function (talk) {
					talk.messages = [];
					talk.new_message = "";
					return talk;
				});
				user.talks = talks;
				user.photos = [];
				user.interested_in = (user.interested_in) ? user.interested_in.split(',') : [];
				user.tags = (user.tags) ? user.tags.split(',') : [];
				ImageModel.getImagesFromUserId(user.id, function(err, imgs, fields){
					if (!err && imgs.length > 0) {
						user.photos = imgs.map(function (img) {
							return [img.id, config.root_url + config.upload_path + img.src];
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
        return formatUser(u, logged);
      });
      callback(users);
		} else {
			console.log(err);
			callback(null);
		}
	});
};

function formatUser(row, logged) {
	row.has_talk = false;
	row.match = "match";
	row.photos = (row.photos) ? row.photos.split(",") : [];
	row.photos = row.photos.map(function (img) {
		return config.root_url + config.upload_path + img;
	});
	row.tags = (row.tags) ? row.tags.split(',') : [];
	row.visitor = (row.visitor != null) ? true : false;
	if (row.localisation && logged.localisation) {
		row.distance = getDistance(JSON.parse(logged.localisation), JSON.parse(row.localisation))
	}
	row.localisation = "secret information";

	return row;
}

ctrl.getVisitors = (logged, callback) => {

  var gender = (logged.interested_in) ? logged.interested_in.split(',') : [];
  var int_in = (logged.gender) ? logged.gender : "M";

  UsersModel.getVisitors(logged.login, gender, int_in, function(err, rows, fields) {
    if (!err) {
      var users = rows.map(function (u) {
        return formatUser(u, logged);
      });
      callback(users);
		} else {
			callback(null);
		}
	});
};

ctrl.getLikers = (logged, callback) => {

  var gender = (logged.interested_in) ? logged.interested_in.split(',') : [];
  var int_in = (logged.gender) ? logged.gender : "M";

  UsersModel.getLikers(logged.login, gender, int_in, function(err, rows, fields) {
    if (!err) {
      var users = rows.map(function (u) {
        return formatUser(u, logged);
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
