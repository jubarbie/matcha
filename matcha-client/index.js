'use strict';


// Require index.html so it gets copied to dist
require('./index.html');

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

	// Holds mousedown state for events. if this
	// flag is active, we move the point on `mousemove`.
	var isDragging;

	// Is the cursor over a point? if this
	// flag is active, we listen for a mousedown event.
	var isCursorOverPoint;

	var coordinates = document.getElementById('coordinates');
	var map = new mapboxgl.Map({
	    container: 'map',
	    style: 'mapbox://styles/mapbox/light-v9',
	    center: [2.4093, 48.8944],
	    zoom: 2
	});

	var canvas = map.getCanvasContainer();

	var geojson = {
	    "type": "FeatureCollection",
	    "features": [{
	        "type": "Feature",
	        "geometry": {
	            "type": "Point",
	            "coordinates": [2.4093, 48.8944]
	        }
	    }]
	};

	function mouseDown() {
	    if (!isCursorOverPoint) return;

	    isDragging = true;

	    // Set a cursor indicator
	    canvas.style.cursor = 'grab';

	    // Mouse events
	    map.on('mousemove', onMove);
	    map.once('mouseup', onUp);
	}

	function onMove(e) {
	    if (!isDragging) return;
	    var coords = e.lngLat;

	    // Set a UI indicator for dragging.
	    canvas.style.cursor = 'grabbing';

	    // Update the Point feature in `geojson` coordinates
	    // and call setData to the source layer `point` on it.
	    geojson.features[0].geometry.coordinates = [coords.lng, coords.lat];
	    map.getSource('point').setData(geojson);
	}

	function onUp(e) {
	    if (!isDragging) return;
	    var coords = e.lngLat;

	    // Print the coordinates of where the point had
	    // finished being dragged to on the map.
	    // coordinates.style.display = 'block';
	    // coordinates.innerHTML = 'Longitude: ' + coords.lng + '<br />Latitude: ' + coords.lat;
	    canvas.style.cursor = '';
	    isDragging = false;

	    // Unbind mouse events
	    map.off('mousemove', onMove);
			app.ports.newLocalisation.send([String(coords.lng), String(coords.lat)]);
	}

	map.on('load', function() {

	    // Add a single point to the map
	    map.addSource('point', {
	        "type": "geojson",
	        "data": geojson
	    });

	    map.addLayer({
	        "id": "point",
	        "type": "circle",
	        "source": "point",
	        "paint": {
	            "circle-radius": 10,
	            "circle-color": "#3887be"
	        }
	    });

	    // When the cursor enters a feature in the point layer, prepare for dragging.
	    map.on('mouseenter', 'point', function() {
	        map.setPaintProperty('point', 'circle-color', '#3bb2d0');
	        canvas.style.cursor = 'move';
	        isCursorOverPoint = true;
	        map.dragPan.disable();
	    });

	    map.on('mouseleave', 'point', function() {
	        map.setPaintProperty('point', 'circle-color', '#3887be');
	        canvas.style.cursor = '';
	        isCursorOverPoint = false;
	        map.dragPan.enable();
	    });

	    map.on('mousedown', mouseDown);
	});
	map.addControl(new mapboxgl.NavigationControl());
});
