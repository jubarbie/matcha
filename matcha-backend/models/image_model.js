const mysql = require('mysql');
const config = require('../config');

let connection = mysql.createConnection(config.database);

exports.getImagesFromUserId = (id, cb) =>
	connection.query('SELECT image.src, image.id FROM image JOIN rel_user_image ON image.id=rel_user_image.id_image WHERE rel_user_image.id_user = ?', [id], cb);

exports.getImageFromId = (id, cb) =>
	connection.query('SELECT * FROM image WHERE id = ?', [id], cb);

exports.getAllImages = (cb) =>
	connection.query('SELECT * FROM image', cb);

exports.addImage = (id_user, path, cb) =>
	connection.query('INSERT INTO image (src) VALUES (?)',[path], function (err, rows, fields) {
		if (!err)
			connection.query('INSERT INTO rel_user_image (id_user, id_image) VALUES (?, LAST_INSERT_ID())',[id_user] , cb);
	});

exports.delImage = (id_user, id_img, cb) =>
	connection.query('DELETE FROM rel_user_image WHERE id_user = ? AND id_image = ?',[id_user, id_img], function (err, rows, fields) {
		if (!err)
			connection.query('DELETE FROM image WHERE id = ?', [id_img], cb);
	});

exports.relUserImage = (id_user, id_img) =>
	connection.query('INSERT INTO rel_user_image (id_user, id_image) VALUES (?, ?)',[id_user, id_img]);
