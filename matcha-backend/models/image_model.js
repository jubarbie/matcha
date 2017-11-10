var mysql = require('mysql');
var config = require('../config');
var connection = mysql.createConnection(config.database);


var model = {};

model.getImagesFromUserId = function(id, cb) {
	connection.query('SELECT image.src FROM image JOIN rel_user_image ON image.id=rel_user_image.id_image WHERE rel_user_image.id_user = ?', [id], cb);
};

module.exports = model;
