'use strict';


// Require index.html so it gets copied to dist
require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode);

app.ports.openNewTab.subscribe(function(url) {
    var win = window.open(url, '_blank');
    win.focus();
});

app.ports.storeToken.subscribe(function(session) {
    window.sessionStorage.setItem('token', session[0]);
});
app.ports.getToken.subscribe(function() {
    var token = window.sessionStorage.getItem('token');

    if (!token) token = "";
    app.ports.tokenRecieved.send([token]);
});
app.ports.deleteSession.subscribe(function() {
    window.sessionStorage.removeItem('token');
});

app.ports.localize.subscribe(function(loc) {

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
        style: 'mapbox://styles/mapbox/dark-v9',
        center: loc,
        zoom: 12
    });

    var canvas = map.getCanvasContainer();

    var geojson = {
        "type": "FeatureCollection",
        "features": [{
            "type": "Feature",
            "geometry": {
                "type": "Point",
                "coordinates": loc
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
        map.flyTo({
            center: e.lngLat
        });
        app.ports.newLocalisation.send([coords.lng, coords.lat]);
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

app.ports.fileSelected.subscribe(function(id) {
    var node = document.getElementById(id);
    if (node === null) {
        return;
    }
    // If your file upload field allows multiple files, you might
    // want to consider turning this into a `for` loop.
    var file = node.files[0];
    var reader = new FileReader();
    // FileReader API is event based. Once a file is selected
    // it fires events. We hook into the `onload` event for our reader.
    if (file.type.indexOf('image') == 0) {
        reader.onload = (function(event) {
            // The event carries the `target`. The `target` is the file
            // that was selected. The result is base64 encoded contents of the file.
            var base64encoded = event.target.result;
            // We build up the `ImagePortData` object here that will be passed to our Elm
            // runtime through the `fileContentRead` subscription.
            var portData = {
                contents: base64encoded,
                filename: file.name
            };
            // We call the `fileContentRead` port with the file data
            // which will be sent to our Elm runtime via Subscriptions.
            app.ports.fileContentRead.send(portData);
        });
        // Connect our FileReader with the file that was selected in our `input` node.
        reader.readAsDataURL(file);
    }
});
