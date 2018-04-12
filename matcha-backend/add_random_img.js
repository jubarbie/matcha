var express = require('express');
var UsersModel = require('./models/users_model');
var ImageModel = require('./models/image_model');
var config = require('./config');


ImageModel.getAllImages((err, imgs, fields) => {
  if (!err && imgs.length > 0) {
    imgs = imgs.map((img) => {
      return img.id;
    });
    UsersModel.getAllUsers((err, rows, fields) => {
      if (!err && rows.length > 0) {
        var yo = rows.map((row) => {
          ImageModel.relUserImage(row.id, imgs[Math.floor(Math.random()*imgs.length)]);
          return row;
        });
        return ;
      } else {
        return ;
      }
    });
  }
});
