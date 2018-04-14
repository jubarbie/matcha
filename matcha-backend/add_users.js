var express = require('express');
var UsersModel = require('./models/users_model');
var ImageModel = require('./models/image_model');
var config = require('./config');
const bcrypt = require('bcrypt');
const saltRounds = 10;



let max = 10;
let users = [];
let now = Date.now();

for (let i = 0; i < max; i++) {

  let user = {};
  let usernameLength = get_random_num(2, 7);
  let username = makeUsername(usernameLength);
  while (users.indexOf(username) > 0) {
    username = makeUsername(usernameLength);
  }

  user.login = username;
  user.lname = makeUsername(get_random_num(2, 7));
  user.fname = makeUsername(get_random_num(2, 7));
  user.email = username + "@42.fr";
  user.password = bcrypt.hashSync("root", saltRounds);
  user.activated = "activated";
  user.rights = 1;
  //let date = get_random_num(1492189607000, 1523725608000);
  now = Date.now();
  UsersModel.insertUser(user, now, (err, row, fields) => {
    if (!err) {
      users.push(username);
      console.log(username + " inserted");
    } else {
      console.log(err);
    }
  });
}

function makeUsername(long) {
  var text = "";
  var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

  for (var i = 0; i < long; i++)
    text += possible.charAt(Math.floor(Math.random() * possible.length));

  return text;
}

function get_random_num(min, max) {
  return  (Math.random() * (max - min) + min);
}
