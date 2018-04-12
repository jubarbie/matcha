var express = require('express');
var UsersModel = require('./models/users_model');
var ImageModel = require('./models/image_model');
var config = require('./config');



UsersModel.getAllUsers((err, users, fields) => {
  console.log(users);
    if (!err && users && users.length > 0) {
        var yo = users.map((user) => {
          ImageModel.getImagesFromUserId(user.id, (err, imgs, field) => {
            if (!err) {
              console.log(imgs);
              let id = (imgs && imgs.length > 0) ? imgs[0].id : null;
              UsersModel.updateField(user.login, 'img_id', id);
              return ;
            } else {
              return ;
            }
          });
          return user;
        });
        return ;
      } else {
        return ;
      }
});
