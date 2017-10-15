'use strict';


// Require index.html so it gets copied to dist
require('./index.html');

var mapboxgl = require('mapbox-gl/dist/mapbox-gl.js');
var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode);

app.ports.storeToken.subscribe(function(session) {
	window.localStorage.setItem('user', session[0]);
	window.localStorage.setItem('token', session[1]);
});
app.ports.getToken.subscribe(function() {
	var token = window.localStorage.getItem('token');
	var user = window.localStorage.getItem('user');

	if (!token) token = "";
	if (!user) user = "";
	app.ports.tokenRecieved.send([user, token]);
});
app.ports.deleteSession.subscribe(function() {
	window.localStorage.removeItem('user');
	window.localStorage.removeItem('token');
});

app.ports.localize.subscribe(function() {
	mapboxgl.accessToken = 'pk.eyJ1IjoianViYXJiaWUiLCJhIjoiY2o4cjV1YmY0MHJtaDJ3cDFhbGZ4aHd2ZCJ9.T1ztr8SLVvZymkDPHCUcBQ';

	var map = new mapboxgl.Map({
	  container: 'map',
	  style: 'mapbox://styles/mapbox/light-v9',
	  center: [2.4093, 48.8944],
	  zoom: 3
	});
	var geojson = {
	  type: 'FeatureCollection',
	  features: [{
	    type: 'Feature',
	    geometry: {
	      type: 'Point',
	      coordinates: [2.4093, 48.8944]
	    },
	    properties: {
	      title: 'Mapbox',
	      description: 'Paris'
	    }
	  }]
	};
	// add markers to map
	geojson.features.forEach(function(marker) {

	  // create a HTML element for each feature
	  var el = document.createElement('div');
	  el.className = 'marker';

	  // make a marker for each feature and add to the map
	  new mapboxgl.Marker(el)
	  .setLngLat(marker.geometry.coordinates)
	  .addTo(map);
	});
});
