var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function(req, res, next) {
	//res.send('respond with a resource');

	res.json([{
		id: 1,
		fname: "Henry",
		lname: "Niseau",
		username: "HenryN",
		date_of_birth: "1986-11-13"
	}, {
		id: 2,
		fname: "Marie",
		lname: "Debord",
		username: "Reveuse",
		date_of_birth: "1990-01-04"
	}, {
		id: 3,
		fname: "Yasine",
		lname: "Drissi",
		username: "Yaya75",
		date_of_birth: "1994-05-20"
	}]);
});

module.exports = router;
