var config = require('../config');

var TalkModel = require('../models/talk_model');

var talk = {};

talk.new_message = (from, to, message) => {

	var usersTab = [from, to].sort();


	TalkModel.getTalkFromUsers(usersTab[0], usersTab[1], function(err, talks, fields) {

		if (talks.length > 0) {
			talkId = talks[0].id;
			var now = Date.now();
			TalkModel.newMessage(talkId, message, from, now, function(err, rows, fields) {
				return true;
			});
		} else {
			return false;
		}

	});
}

module.exports = talk;
