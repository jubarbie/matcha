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
                    "status": "success",
                    "data": tags
                });
            } else {
                res.json({
                    "status": "error",
                    "msg": "problem in request"
                });
            }
        });
    } else {
        res.json({
            "status": "error",
            "msg": "Missing search"
        });
    }
});

/* Adding tag */
router.post('/add', (req, res, next) => {

    var logged = req.logged_user;
    var tag = req.body.tag;

    if (logged && tag) {
        TagModel.addTag(logged.login, tag, (err, rows, fields) => {
            if (!err) {
                TagModel.getTagsFromLogin(logged.login, (err, tags, fields) => {
                    if (!err) {
                        if (tags.length > 0) {
                            tags = tags.map((tag) => {
                                return tag.tag;
                            });
                        }
                        console.log(tags);
                        res.json({
                            "status": "success",
                            "data": tags
                        });
                    } else {
                        console.log(err);
                        res.json({
                            "status": "error",
                            "msg": "Missing search"
                        });
                    }
                });
            } else {
                console.log(err);
                res.json({
                    "status": "error"
                });
            }
        });
    } else {
        console.log("oup");
        res.json({
            "status": "error",
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
                        console.log(tags);
                        res.json({
                            "status": "success",
                            "data": tags
                        });
                    } else {
                        console.log(err);
                        res.json({
                            "status": "error",
                            "msg": "Missing search"
                        });
                    }
                });
            } else {
                console.log(err);
                res.json({
                    "status": "error"
                });
            }
        });
    } else {
        console.log("oup");
        res.json({
            "status": "error",
            "msg": "Missing args"
        });
    }

});

module.exports = router;