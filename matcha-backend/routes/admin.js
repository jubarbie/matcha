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

/* GET all users */
router.get('/users', (req, res, next) => {

  UserCtrl.getAllProfiles().then(users => {
      res.json({
          "status": true,
          "data": users
      });
    }).catch(err => {
      res.json({
          "status": false,
          "msg": "A problem occur while fetching users"
      });
    });

});

/* GET reported users */
router.get('/reported_users', (req, res, next) => {

    UserCtrl.getReportedUsers().then(users => {
      res.json({
          "status": true,
          "data": users
      });
    }).catch(err => {
        res.json({
            "status": false,
            "msg": "A problem occur while fetching users" + err
        });
    });

});

/* DELETE user */
router.get('/delete/:username', (req, res, next) => {

    const username = req.params.username;

    if (!username) {
      res.json({
          "status": false,
          "msg": "A problem occur while fetching users"
      });
    } else {
      UsersModel.deleteUser(username, (err, result) => {
        if (err) {
          res.json({
              "status": false,
              "msg": "A problem occur while fetching users :" + err
          });
        } else {
          res.json({
            "status": true,
            "msg": result.affectedRows + " rows affected"
          });
        }
      });
    }

});

module.exports = router;
