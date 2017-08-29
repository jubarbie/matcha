// ************************************************************************** //
//                                                                            //
//                                                        :::      ::::::::   //
//   app.js                                             :+:      :+:    :+:   //
//                                                    +:+ +:+         +:+     //
//   By: jubarbie <marvin@42.fr>                    +#+  +:+       +#+        //
//                                                +#+#+#+#+#+   +#+           //
//   Created: 2017/08/29 10:46:15 by jubarbie          #+#    #+#             //
//   Updated: 2017/08/29 10:46:20 by jubarbie         ###   ########.fr       //
//                                                                            //
// ************************************************************************** //

var express = require('express');
var app = express();

app.get('/', function (req, res) {
	  res.send('Hello World!');
});

app.listen(3000, function () {
	  console.log('Example app listening on port 3000!');
});
