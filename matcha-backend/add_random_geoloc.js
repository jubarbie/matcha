var express = require('express');
var UsersModel = require('./models/users_model');
var ImageModel = require('./models/image_model');
var config = require('./config');


UsersModel.getAllUsers((err, rows, fields) => {
  if (!err && rows.length > 0) {
    console.log(rows);
    var yo = rows.map((row) => {
      UsersModel.updateLocation(row.login, get_random_loc(2.271423,48.840317,2.409439,48.901741));
      return row;
    });
    return ;
  } else {
    return ;
  }
});


function get_random_loc(min_lon, min_lat, max_lon, max_lat) {
  var loc = {};
  loc.lon = (Math.random() * (max_lon - min_lon) + min_lon).toFixed(12);
  loc.lat = (Math.random() * (max_lat - min_lat) + min_lat).toFixed(12);
  return JSON.stringify(loc);
}
