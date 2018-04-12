var express = require('express');
var router = express.Router();

var config = require('../config');
var TagModel = require('../models/tag_model');
var UserModel = require('../models/users_model');

/* Searching tag */
router.post('/search', (req, res, next) => {

    var search = req.body.search + "%";

    if (search) {
        TagModel.searchTags(search, (err, tags, fields) => {
            if (!err) {
                if (tags.length > 0) {
                    tags = tags.map((tag) => {
                        return tag.tag;
                    });
                }
                res.json({
                    "status": true,
                    "data": tags
                });
            } else {
                res.json({
                    "status": false,
                    "msg": "problem in request"
                });
            }
        });
    } else {
        res.json({
            "status": false,
            "msg": "Missing search"
        });
    }
});

/* Adding tag */
router.post('/add', (req, res, next) => {

    var logged = req.logged_user;
    var tag = req.body.tag;

    if (logged && tag) {
        if (tag.length > 30) {
          res.json({
              "status": false,
              "msg": "Tag too long. 30 char max."
          });
        } else {
          TagModel.addTag(logged.login, tag, (err, rows, fields) => {
              if (!err) {
                  TagModel.getTagsFromLogin(logged.login, (err, tags, fields) => {
                      if (!err) {
                          if (tags.length > 0) {
                              tags = tags.map((tag) => {
                                  return tag.tag;
                              });
                          }
                          res.json({
                              "status": true,
                              "data": tags
                          });
                      } else {
                          res.json({
                              "status": false,
                              "msg": "Missing search"
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
    } else {
        res.json({
            "status": false,
            "msg": "Missing args"
        });
    }

});

/* Adding tag */
router.post('/remove', (req, res, next) => {

    var logged = req.logged_user;
    var tag = req.body.tag;

    if (logged && tag) {
        TagModel.removeTag(logged.login, tag, (err, rows, fields) => {
            if (!err) {
                TagModel.getTagsFromLogin(logged.login, (err, tags, fields) => {
                    if (!err) {
                        if (tags.length > 0) {
                            tags = tags.map((tag) => {
                                return tag.tag;
                            });
                        }
                        res.json({
                            "status": true,
                            "data": tags
                        });
                    } else {
                        res.json({
                            "status": false,
                            "msg": "Missing search"
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
            "msg": "Missing args"
        });
    }

});

module.exports = router;
