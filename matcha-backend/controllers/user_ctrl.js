const config = require('../config');
const UsersModel = require('../models/users_model');
const LikesModel = require('../models/likes_model');
const TalkModel = require('../models/talk_model');
const ImageModel = require('../models/image_model');


exports.getFullUser = (logged, login, callback) => {
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

exports.getConnectedUser = login => {
  return new Promise((resolve, reject) => {
    UsersModel.getUserWithLogin(login, (err, rows, fields) => {
      if (err)
        return reject(err);
      else if (rows.length == 0)
        return reject("No user found");
      else
        return resolve(formatSessionUser(rows[0]));
    })
  });
};

exports.getRelevantUsers = (logged, callback) => {

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

exports.getAllProfiles = () => {

    return new Promise((resolve, reject) => {
      UsersModel.getAllProfiles((err, rows, fields) => {
          if (err)
            return reject (err);
          else
            return resolve(rows.map(u => {
                  return formatSessionUser(u);
              }));
          })
    });

};

exports.getAdvanceSearch = (logged, searchLogin, searchTags, min, max, dist, callback) => {

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

exports.getVisitors = (logged, callback) => {

    var gender = (logged.interested_in) ? logged.interested_in.split(',') : ["M", "F", "O", "NB"];
    var int_in = (logged.gender) ? logged.gender : "M";

    UsersModel.getVisitors(logged.login, gender, int_in, function(err, rows, fields) {
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

exports.getMatchers = (logged, callback) => {

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

exports.getLikers = (logged, callback) => {

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

exports.getReportedUsers = () => {
  return new Promise((resolve, reject) => {
    UsersModel.getReportedUsers((err, rows, fields) => {
      if (err)
        return reject(err);
      else
        return resolve(rows.map(user => formatSessionUser(user)));
    })
  });
}

exports.is_blocked = (from, to, cb) => {

  UsersModel.getBlocked(from, to, (err, rows, fields) => {
    if (!err) {
      if (rows.length > 0) {
        cb(true);
      } else {
        cb(false);
      }
    } else {
      cb(false);
    }
  });

}

let getDistance = (pos_from, pos_to) => {

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

let deg2rad = (deg) => {
    return deg * (Math.PI / 180)
}

let formatSessionUser = (row) => {
  let user = row;
  user.talks = (user.talks) ? user.talks.split(',').map(t => {
      t = t.split(';')[0];
      t.messages = [];
      t.new_message = "";
      return t;
  }) : [];
  user.interested_in = (user.interested_in) ? user.interested_in.split(',') : [];
  user.tags = (user.tags) ? user.tags.split(',') : [];
  user.images = (user.images) ? user.images.split(',').map((line) => {
    let img = line.split(";");
    img[0] = parseInt(img[0]);
    img[1] = config.root_url + "upload/images/" + img[1];
    img[2] = (img[2] == 1);
    return img;
  } ) : [];
  if (user.localisation) {
      user.localisation = JSON.parse(user.localisation);
  } else {
      user.localisation = {
          'lon': 0,
          'lat': 0
      };
  }
  return user;
}

let formatUser = (row, logged) => {
    row.has_talk = false;
    row.interested_in = (row.interested_in) ? row.interested_in.split(",") : ["M", "F", "O", "NB"];
    row.images = (row.images) ? row.images.split(',').map((line) => {
      let img = line.split(";");
      img[0] = parseInt(img[0]);
      img[1] = config.root_url + "upload/images/" + img[1];
      img[2] = (img[2] == 1);
      return img;
    } ) : [];
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
