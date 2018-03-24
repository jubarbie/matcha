var config = require('../config');

var UsersModel = require('../models/users_model');
var LikesModel = require('../models/likes_model');
var TalkModel = require('../models/talk_model');
var ImageModel = require('../models/image_model');

var ctrl = {};

ctrl.getFullUser = (logged, login, callback) => {
    UsersModel.getFullDataUserWithLogin(logged.login, login, (err, rows, fields) => {
        if (!err && rows.length > 0) {
            var user = formatUser(rows[0], logged);
            callback(user);
        } else {
            console.log(err);
            callback(null);
        }
    });
};

function getDistance(pos_from, pos_to) {

    let R = 6371; // Radius of the earth in km
    let dLat = deg2rad(pos_to.lat - pos_from.lat); // deg2rad below
    let dLon = deg2rad(pos_to.lon - pos_from.lon);
    let a =
        Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(deg2rad(pos_from.lat)) * Math.cos(deg2rad(pos_to.lat)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);
    let c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    let d = R * c; // Distance in km

    return d;
}

function deg2rad(deg) {
    return deg * (Math.PI / 180)
}

ctrl.getConnectedUser = function(login, callback) {
    UsersModel.getUserWithLogin(login, function(err, rows, fields) {
        if (!err && rows.length > 0) {
            var user = rows[0];
            TalkModel.getUserTalks(login, function(err, talks, fields) {
                talks.map(function(talk) {
                    talk.messages = [];
                    talk.new_message = "";
                    return talk;
                });
                user.talks = talks;
                user.photos = [];
                user.interested_in = (user.interested_in) ? user.interested_in.split(',') : [];
                user.tags = (user.tags) ? user.tags.split(',') : [];
                ImageModel.getImagesFromUserId(user.id, function(err, imgs, fields) {
                    if (!err && imgs.length > 0) {
                        user.photos = imgs.map(function(img) {
                            return [img.id, config.root_url + config.upload_path + img.src];
                        });
                    }
                    if (user.localisation) {
                        user.localisation = JSON.parse(user.localisation);
                    } else {
                        user.localisation = {
                            'lon': 0,
                            'lat': 0
                        };
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

    var gender = (logged.interested_in) ? logged.interested_in.split(',') : ["M", "F", "O", "NB"];
    var int_in = (logged.gender) ? logged.gender : "M";

    UsersModel.getRelevantProfiles(logged.login, gender, int_in, function(err, rows, fields) {
        if (!err) {
            var users = rows.map(function(u) {
                return formatUser(u, logged);
            });
            callback(users);
        } else {
            console.log(err);
            callback(null);
        }
    });
};

ctrl.getAdvanceSearch = (logged, searchLogin, searchTags, min, max, dist, callback) => {

    var gender = (logged.interested_in) ? logged.interested_in.split(',') : ["M", "F", "O", "NB"];
    var int_in = (logged.gender) ? logged.gender : "M";

    UsersModel.getAdvanceSearch(logged.login, gender, int_in, searchLogin, searchTags, min, max, function(err, rows, fields) {
        if (!err) {
            var users = rows.map(function(u) {
                return formatUser(u, logged);
            });
            if (dist)
                users = users.filter(user => user.distance <= dist);
            callback(users);
        } else {
            console.log(err);
            callback(null);
        }
    });
};

function formatUser(row, logged) {
    row.has_talk = false;
    row.photos = (row.photos) ? row.photos.split(",") : ["M", "F", "O", "NB"];
    row.photos = row.photos.map(function(img) {
        return config.root_url + config.upload_path + img;
    });
    row.tags = (row.tags) ? row.tags.split(',') : [];
    row.visitor = (row.visitor != null) ? true : false;
    if (row.localisation && logged.localisation) {
        row.distance = getDistance(JSON.parse(logged.localisation), JSON.parse(row.localisation))
    }
    row.localisation = "secret information";
    row.liked = (row.liked > 0);
    row.liking = (row.liking > 0);
    row.online = (row.online == 1);

    return row;
}

ctrl.getVisitors = (logged, callback) => {

    var gender = (logged.interested_in) ? logged.interested_in.split(',') : ["M", "F", "O", "NB"];
    var int_in = (logged.gender) ? logged.gender : "M";

    UsersModel.getVisitors(logged.login, gender, int_in, function(err, rows, fields) {
        if (!err) {
            var users = rows.map(function(u) {
                return formatUser(u, logged);
            });
            callback(users);
        } else {
            callback(null);
        }
    });
};

ctrl.getMatchers = (logged, callback) => {

    var gender = (logged.interested_in) ? logged.interested_in.split(',') : ["M", "F", "O", "NB"];
    var int_in = (logged.gender) ? logged.gender : "M";

    UsersModel.getMatchers(logged.login, gender, int_in, function(err, rows, fields) {
        if (!err) {
            var users = rows.map(function(u) {
                return formatUser(u, logged);
            });
            callback(users);
        } else {
            console.log(err);
            callback(null);
        }
    });
};

ctrl.getLikers = (logged, callback) => {

    var gender = (logged.interested_in) ? logged.interested_in.split(',') : ["M", "F", "O", "NB"];
    var int_in = (logged.gender) ? logged.gender : "M";

    UsersModel.getLikers(logged.login, gender, int_in, function(err, rows, fields) {
        if (!err) {
            var users = rows.map(function(u) {
                return formatUser(u, logged);
            });
            callback(users);
        } else {
            callback(null);
        }
    });
};

module.exports = ctrl;