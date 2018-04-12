const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const fs = require('fs');
const saltRounds = 10;
const shortid = require('shortid');
const base64 = require('node-base64-image');
const config = require('../config');
const validation = require('../middlewares/validation.js');
const UserCtrl = require('../controllers/user_ctrl.js');
const UsersModel = require('../models/users_model');
const VisitsModel = require('../models/visits_model');
const LikesModel = require('../models/likes_model');
const TalkModel = require('../models/talk_model');
const ImageModel = require('../models/image_model');
const ReportsModel = require('../models/reports_model');

const genders = ['M', 'F', 'NB', 'O'];

/* GET users */
router.get('/relevant_users', (req, res, next) => {

    const logged = req.logged_user;

    UserCtrl.getRelevantUsers(logged, function(users) {
        if (users) {
            res.json({
                "status": true,
                "data": users
            });
        } else {
            res.json({
                "status": false,
                "msg": "A problem occur while fetching users"
            });
        }
    });

});


router.post('/search', (req, res, next) => {

    const logged = req.logged_user;
    let searchLogin = req.body.searchLogin;
    let searchTags = req.body.searchTags;
    let searchMin = req.body.searchMin;
    let searchMax = req.body.searchMax;
    let searchLoc = req.body.searchLoc;


    UserCtrl.getAdvanceSearch(logged, searchLogin, searchTags, searchMin, searchMax, searchLoc, function(users) {
        if (users) {
            res.json({
                "status": true,
                "data": users
            });
        } else {
            res.json({
                "status": false,
                "msg": "A problem occur while fetching users"
            });
        }
    });

});


/* GET users that visited connect user */
router.get('/visitors', (req, res, next) => {

    const logged = req.logged_user;

    var now = Date.now();
    UserCtrl.getVisitors(logged, function(users) {
        if (users) {
            VisitsModel.updateVisitLast(logged.login, now);
            res.json({
                "status": true,
                "data": users
            });
        } else {
            res.json({
                "status": false,
                "msg": "A problem occur while fetching users"
            });
        }
    });

});

/* GET users that liked connected user */
router.get('/likers', (req, res, next) => {

    const logged = req.logged_user;
    const now = Date.now();

    UserCtrl.getLikers(logged, function(users) {
        if (users) {
            LikesModel.updateLikeLast(logged.login, now);
            res.json({
                "status": true,
                "data": users
            });
        } else {
            res.json({
                "status": false,
                "msg": "A problem occur while fetching users"
            });
        }
    });

});

/* GET users that liked connected user */
router.get('/matchers', (req, res, next) => {

    const logged = req.logged_user;
    const now = Date.now();

    UserCtrl.getMatchers(logged, function(users) {
        if (users) {
            LikesModel.updateLikeLast(logged.login, now);
            res.json({
                "status": true,
                "data": users
            });
        } else {
            res.json({
                "status": false,
                "msg": "A problem occur while fetching users"
            });
        }
    });

});

/* GET user with login */
router.get('/user/:login', (req, res, next) => {

    const login = req.params.login;
    const logged = req.logged_user;

    sendUser(logged, login, res)

});

/* GET connected user */
router.get('/connected_user', (req, res, next) => {

    const logged = req.logged_user;

    UserCtrl.getConnectedUser(logged.login, function(user) {
        if (user) {
            delete user.password;
            res.json({
                "status": true,
                "data": user
            });
        } else {
            res.json({
                "status": false,
                "msg": "User " + logged.login + " doesn't exists"
            });
        }
    });

});

/* GET user with login */
router.get('/disconnect', (req, res, next) => {

    const logged = req.logged_user;

    var now = Date.now();
    UsersModel.updateConnectionDate(logged.id, now, null, (err, rows, fields) => {
        res.json({
            "status": true,
        });
    });

});

function sendUser(logged, login, res) {
    UserCtrl.getFullUser(logged, login, function(user) {
        if (user) {
            res.json({
                "status": true,
                "data": user
            });
        } else {
            res.json({
                "status": false,
                "msg": "Error when fetching user"
            });
        }
    });
}

/* Like or unlike user. */
router.post('/toggle_like', (req, res, next) => {

    var username = req.body.username;
    var logged = req.logged_user;

    if (logged && username) {
        LikesModel.getLikeBetweenUsers(logged.login, username, function(err, rows, fields) {
            if (rows[0]) {
                LikesModel.unLike(logged.login, username, function(err, rows, fields) {
                    if (rows) {
                        sendUser(logged, username, res);
                    } else {
                        res.json({
                            "status": false
                        });
                    }
                });
            } else {
                var now = Date.now();
                LikesModel.like(logged.login, username, now, function(err, rows, fields) {
                    if (rows) {
                        sendUser(logged, username, res)
                    } else {
                        res.json({
                            "status": false
                        });
                    }
                });
            }
        });
    } else {
        res.json({
            "status": false
        });
    }
});

/* Report user */
router.get('/report/:login', (req, res, next) => {

    var username = req.params.login;
    var logged = req.logged_user;

    if (logged && username) {
        var now = Date.now();
        ReportsModel.addReport(logged.login, username, now, function(err, rows, fields) {
            if (rows) {
                res.json({
                    "status": true
                });
            } else {
                res.json({
                    "status": false
                });
            }
        });
    } else {
        res.json({
            "status": false
        });
    }
});

/* Report user */
router.get('/block/:login', (req, res, next) => {

    var username = req.params.login;
    var logged = req.logged_user;

    if (logged && username) {
        var now = Date.now();
        ReportsModel.addBlock(logged.login, username, now, function(err, rows, fields) {
            if (rows) {
                res.json({
                    "status": true
                });
            } else {
                res.json({
                    "status": false
                });
            }
        });
    } else {
        res.json({
            "status": false
        });
    }
});

/* Update user infos */
router.post('/update', (req, res, next) => {

    const valid = validation.validateUserInfos(req);
    var logged = req.logged_user;

    if (logged, valid.valid) {
        UsersModel.updateInfos(logged.login, valid.data, "activated", function(err, rows, fields) {
            if (rows && !err) {
                res.json({
                    "status": true
                });
            } else {
                res.json({
                    "status": false
                });
            }
        });
    } else {
        res.json({
            "status": false,
            "msg": "invalid form"
        })
    }
});

/* Update specific field */
router.post('/update_gender', (req, res, next) => {

    const gender = req.body.gender;
    var logged = req.logged_user;

    if (logged) {
        if (!gender || !genders.includes(gender)) {
            res.json({
                "status": false,
                "msg": "invalid form"
            });
        } else {
            UsersModel.updateField(logged.login, "gender", req.body.gender, (err, rows, fields) => {
                if (!err) {
                    UserCtrl.getConnectedUser(logged.login, (user) => {
                        if (user) {
                            res.json({
                                "status": true,
                                "data": user
                            });
                        } else {
                            res.json({
                                "status": false
                            });
                        }
                    });
                } else {
                    res.json({
                        "status": false
                    });
                }
            });
        }
    }
});

/* Update specific field */
router.post('/update_int_in', (req, res, next) => {

    var logged = req.logged_user;
    let int_in = req.body.genders;

    if (logged) {
        if (!(int_in && int_in.reduce((a, c) => a & genders.includes(c), true))) {
            res.json({
                "status": false,
                "msg": "invalid form"
            });
        } else {
            int_in = int_in.map((gender) => {
                return [logged.login, gender];
            });
            UsersModel.updateSexuality(logged.login, int_in, (err, rows, fields) => {
                if (!err) {
                    sendConnectedUser(logged, res);
                } else {
                    res.json({
                        "status": false
                    });
                }
            });
        }
    }
});

/* Update specific field */
router.post('/update_dob', (req, res, next) => {

    var logged = req.logged_user;
    let dob = req.body.dob;

    if (logged) {
        if (!(Number.isInteger(dob) && dob < (new Date()).getFullYear() - 18 && dob >= 1900)) {
            res.json({
                "status": false,
                "msg": "invalid form"
            });
        } else {
            UsersModel.updateField(logged.login, 'birth',dob, (err, rows, fields) => {
                if (!err) {
                    sendConnectedUser(logged, res);
                } else {
                    res.json({
                        "status": false
                    });
                }
            });
        }
    }
});

function sendConnectedUser(logged, res) {
    UserCtrl.getConnectedUser(logged.login, (user) => {
        if (user) {
            res.json({
                "status": true,
                "data": user
            });
        } else {
            res.json({
                "status": false
            });
        }
    });
}

/* Update user password */
router.post('/change_password', (req, res, next) => {

    var logged = req.logged_user;
    var oldPwd = req.body.oldPwd;
    var newPwd = req.body.newPwd;

    if (logged) {
        if (!(oldPwd && newPwd && newPwd.length > 5 && newPwd.match(/\d/))) {
            res.json({
                "status": false,
                "msg": "invalid form"
            });
        } else {
            UsersModel.getUserWithLogin(logged.login, (err, users, fields) => {
                if (!err && users.length > 0) {
                    var user = users[0];
                    if (bcrypt.compareSync(oldPwd, user.password) == false) {
                        res.json({
                            "status": false,
                            "msg": "Incorrect password"
                        });
                    } else {
                        var password = bcrypt.hashSync(newPwd, saltRounds);
                        UsersModel.updatePassword(logged.login, password, "activated", (err, rows, fields) => {
                            if (rows && !err) {
                                res.json({
                                    "status": true
                                });
                            } else {
                                res.json({
                                    "status": false
                                });
                            }
                        });
                    }
                } else {
                    res.json({
                        "status": false
                    });
                }
            })

        }
    }
});

/* Like or unlike user. */
router.post('/save_loc', (req, res, next) => {

    var lat = req.body.lat;
    var lon = req.body.lon;
    var logged = req.logged_user;

    if (logged && lat && lon && !isNaN(lat) && !isNaN(lon)) {
        var loc = {};
        loc.lon = lon;
        loc.lat = lat;
        UsersModel.updateLocation(logged.login, JSON.stringify(loc), (err, rows, fields) => {
            if (!err) {
                res.json({
                    "status": true
                });
            } else {
                res.json({
                    "status": false
                });
            }
        });
    } else {
        res.json({
            "status": false
        });
    }

});

/* Like or unlike user. */
router.post('/new_image', (req, res, next) => {

    var logged = req.logged_user;
    var b64string = req.body.img;

    if (logged && b64string) {
        ImageModel.getImagesFromUserId(logged.id, (err, imgs, fields) => {
            if (!err) {
                if (imgs.length < 5) {
                    var img = decodeBase64Image(b64string);
                    var type = '.' + img.type.split('/')[1];
                    var imgName = shortid.generate();
                    base64.decode(img.data, {
                        filename: 'public/' + config.upload_path + imgName
                    }, (err) => {
                        if (!err) {
                            ImageModel.addImage(logged.id, imgName + '.jpg', (err, rows, fields) => {
                                if (!err) {
                                    UserCtrl.getConnectedUser(logged.login, (user) => {
                                        if (user) {
                                            res.json({
                                                "status": true,
                                                "data": user
                                            });
                                        } else {
                                            res.json({
                                                "status": false
                                            });
                                        }
                                    });
                                } else {
                                    res.json({
                                        "status": false
                                    });
                                }
                            });
                        } else {
                            res.json({
                                "status": false
                            });
                        }
                    });
                } else {
                    res.json({
                        "status": false,
                        "msg": "Too many images"
                    });
                }
            } else {
                res.json({
                    "status": false
                });
            }
        });
    } else {
        res.json({
            "status": false
        });
    }

});

/* Delete image */
router.post('/del_image', (req, res, next) => {

    var logged = req.logged_user;
    var id_img = req.body.id_img;

    if (logged && id_img) {
        ImageModel.getImageFromId(id_img, (err, imgs, fields) => {
            if (!err && imgs.length > 0) {
                var path = "public/" + config.upload_path + imgs[0].src;
                ImageModel.delImage(logged.id, id_img, (err, rows, fields) => {
                    if (!err) {
                        fs.unlink(path, (err) => {
                            UserCtrl.getConnectedUser(logged.login, (user) => {
                                if (user) {
                                    res.json({
                                        "status": true,
                                        "data": user
                                    });
                                } else {
                                    res.json({
                                        "status": false
                                    });
                                }
                            });
                        });
                    } else {
                        res.json({
                            "status": false
                        });
                    }
                });
            }
        });
    } else {
        res.json({
            "status": false
        });
    }

});

/* Like or unlike user. */
router.post('/update_main_image', (req, res, next) => {

  var logged = req.logged_user;
  var id_img = req.body.id_img;

  if (logged && id_img) {
      ImageModel.getImageFromUserAndId(logged.id, id_img, (err, imgs, fields) => {
        if (!err) {
          if (imgs.length > 0) {
            UsersModel.updateField(logged.login, 'img_id', id_img);
            sendConnectedUser(logged, res);
          } else {
            res.json({
                "status": false,
                "msg": "The image does not belong to this user"
            });
          }
        } else {
          res.json({
              "status": false,
              "msg": "An error occured while updting profile picture"
          });
        }
      });
  }
});

function decodeBase64Image(dataString) {
    var matches = dataString.match(/^data:([A-Za-z-+\/]+);base64,(.+)$/),
        response = {};

    if (matches.length !== 3) {
        return new Error('Invalid input string');
    }

    response.type = matches[1];
    response.data = new Buffer(matches[2], 'base64');

    return response;
}

module.exports = router;
