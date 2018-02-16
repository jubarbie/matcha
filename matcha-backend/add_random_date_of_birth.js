var express = require('express');
var UsersModel = require('./models/users_model');
var ImageModel = require('./models/image_model');
var config = require('./config');


UsersModel.getAllUsers((err, rows, fields) => {
  if (!err && rows.length > 0) {
    var yo = rows.map((row) => {
      UsersModel.updateField(row.login, "birth", get_random_birth(1919, 1978));
      return row;
    });
    return ;
  } else {
    return ;
  }
});


function get_random_birth(min, max) {
  return  (Math.random() * (max - min) + min);
}
