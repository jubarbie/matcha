var mysqlDump = require('mysqldump');
var config = require('./config');
var db = config.database;

mysqlDump({
    host     : db.host,
	port     : db.port,
	user     : db.user,
	password : db.password,
    database : db.database,
    dest: './database.sql'
},function(err) {
    console.log('Database saved');
    // create data.sql file;
})
