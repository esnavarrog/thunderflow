$(document).on('turbolinks:load', common_events);

function common_events() {
  if ($('#map-driver-positions').length > 0) initDriverPositionsMap();
  $('#refresh-map').off('click').on('click', fetchPositions);
}

let map;
let markers = [];
let destinationMarkers = [];
let fetchIntervalId;

function clearMarkers() {
  markers.forEach(m => m.setMap(null));
  markers = [];
  destinationMarkers.forEach(m => m.setMap(null));
  destinationMarkers = [];
}

function addMarkers(positions) {
  positions.forEach(function(pos) {
    // Driver marker
    const marker = new google.maps.Marker({
      position: { lat: pos.latitude, lng: pos.longitude },
      map: map,
      label: pos.user.name,
      title: pos.user.name
    });
    markers.push(marker);

    // Destination marker (if present)
    if (pos.destination_latitude && pos.destination_longitude) {
      const destMarker = new google.maps.Marker({
        position: { lat: pos.destination_latitude, lng: pos.destination_longitude },
        map: map,
        icon: 'http://maps.google.com/mapfiles/ms/icons/blue-dot.png',
        label: "Destino",
        title: `Destino de ${pos.user.name}`
      });
      destinationMarkers.push(destMarker);
    }
  });
}

function fetchPositions() {
  const url = $('#map-driver-positions').data('positions-url');
  $.getJSON(url, function(data) {
    clearMarkers();
    addMarkers(data);
  });
}

function initDriverPositionsMap() {
  map = new google.maps.Map(document.getElementById('map-driver-positions'), {
    center: { lat: -33.45, lng: -70.6667 },
    zoom: 12
  });
  fetchPositions();
  if (fetchIntervalId) clearInterval(fetchIntervalId);
  fetchIntervalId = setInterval(fetchPositions, 30000);
}
