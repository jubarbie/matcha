var express = require('express');
var UsersModel = require('./models/users_model');
var TagModel = require('./models/tag_model');
var config = require('./config');
var tags = require('./tags.json');

var allTags = tags.tags;


UsersModel.getAllUsers((err, rows, fields) => {
  if (!err && rows.length > 0) {
    var nbTags = allTags.length;
    var yo = rows.map((row) => {
      var size = getRandomInt(21);
      var tags = [];
      for (var i = 0; i < size; i++) {
        var tag = allTags[getRandomInt(21)];
        if (!tags.includes(tag)) {
          tags[i] = tag;
          TagModel.addTag(row.login, tag);
        }
      }
      return row;
    });
    return ;
  } else {
    return ;
  }
});


function getRandomInt(max) {
  return Math.floor(Math.random() * Math.floor(max));
}
