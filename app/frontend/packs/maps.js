
function initMap() {
    const coords = document.getElementById("brewers");
    const coords_branch = document.getElementById("brewers-branch");
    
    
    if (coords && coords_branch){
        let latitude = parseFloat(coords.getAttribute("data-lat"));
        let longitude = parseFloat(coords.getAttribute("data-long"));
        let latitude_branch = parseFloat(coords_branch.getAttribute("data-lat"));
        let longitude_branch = parseFloat(coords_branch.getAttribute("data-long"));

        determinateNavigator(latitude, longitude);
          // Crea el objeto de opciones del mapa y establece el estilo del mapa
        var mapOptions = {
            zoom: 16,
            center: {lat: latitude, lng: longitude},
            mapId: "8ccbea4ce4308a7b",
            disableDefaultUI: true,
            mapTypeControl: false
        };
        
        var map = new google.maps.Map(document.getElementById('map'), mapOptions);
    
        var distanceService = new google.maps.DistanceMatrixService();
    
        var destino = new google.maps.LatLng(latitude, longitude);
        var origen = new google.maps.LatLng(latitude_branch, longitude_branch);
    
        var request = {
            origins: [origen],
            destinations: [destino],
            travelMode: google.maps.TravelMode.DRIVING,
            unitSystem: google.maps.UnitSystem.METRIC,
            avoidHighways: false,
            avoidTolls: false
        };
    
        // Llama al servicio de matriz de distancia
        distanceService.getDistanceMatrix(request, function(response, status) {
            if (status == google.maps.DistanceMatrixStatus.OK) {
                try {
                    var distancia = response.rows[0].elements[0].distance.value;
                } catch (error) {
                    console.error(error)
                }
            }
        });
        // Crea el objeto de solicitud de dirección
        var solicitud = {
            origin: origen,
            destination: destino,
            travelMode: google.maps.TravelMode.DRIVING // Puedes utilizar otros modos de transporte como WALKING, BICYCLING, o TRANSIT
        };
    
        // Crea un objeto DirectionsService y envía la solicitud
        var directionsService = new google.maps.DirectionsService();
        directionsService.route(solicitud, function(resultado, estado) {
            if (estado == google.maps.DirectionsStatus.OK) {
                // Crea un objeto DirectionsRenderer y muestra la ruta en el mapa
                var directionsRenderer = new google.maps.DirectionsRenderer();
                directionsRenderer.setMap(map);
                directionsRenderer.setDirections(resultado);
            } else {
                alert('No se pudo generar la ruta debido a: ' + estado);
            }
        });
    }
}

function distanceDelivery(lat_origin, long_origin, lat_destination, long_destination){
    var destino = new google.maps.LatLng(lat_destination, long_destination);
    var origen = new google.maps.LatLng(lat_origin, long_origin);
    var distanceService = new google.maps.DistanceMatrixService();

    var request = {
        origins: [origen],
        destinations: [destino],
        travelMode: google.maps.TravelMode.DRIVING,
        unitSystem: google.maps.UnitSystem.METRIC,
        avoidHighways: false,
        avoidTolls: false
    };

    distanceService.getDistanceMatrix(request, function(response, status) {
        if (status == google.maps.DistanceMatrixStatus.OK) {
            try {
                var distancia = response.rows[0].elements[0].distance.value;
            } catch (error) {
                console.error(error)
            }
            var price;
            // $.ajax({
            //     url:'/price_for_distance',
            //     dataType: 'json',
            //     method: 'GET',
            //     data:{
            //         distance: distancia/1000
            //     },
            //     success: function(data){
            //         $('#price-distance-delivery').html("Valor estimado: $ "+formatNumber(data.price))
            //     }
            // })
            $('#delivery_distance_meters').val(distancia)
            $('#data-distance-delivery').removeClass('d-none').find('span').html(distancia/1000)
        }
    });

}

function formatNumber(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");
}

function launchmap(lat, lng, klass){

    var myLatLng;
    if(lat && lng){
        myLatLng = {lat:lat,lng:lng}
    }else{
        myLatLng = {lat:-33.404900,lng:-70.591324}
    }
    
    var mapOptions = {
        zoom: 16,
        center: myLatLng,
        mapId: "8ccbea4ce4308a7b",
        disableDefaultUI: true,
        mapTypeControl: false
    };

    var map = document.getElementById(klass+'map');

    if (map == null) {return}

    const mapa = new google.maps.Map(map, mapOptions);

    const marcador = new google.maps.Marker({
        position: myLatLng,
        map: mapa
    });

    var information = new google.maps.InfoWindow()

    marcador.addListener('click', function(){
        information.open(mapa, marcador)
    })

    var autocomplete = document.getElementById(klass+'address_concat');

    const search = new google.maps.places.Autocomplete(autocomplete);
    search.bindTo('bounds', mapa);

    search.addListener('place_changed', function(){
        information.close();
        marcador.setVisible(false);
        var place = search.getPlace();

        if(!place.geometry.viewport){
            window.alert('Error al mostrar el lugar');
            return;
        }
        if(place.geometry.viewport){
            mapa.fitBounds(place.geometry.viewport);
        }else{
            mapa.setCenter(place.geometry.location);
            mapa.setZoom(18);
        }

        let lat_origin = $('#branch_latlng').data('latitude')
        let lng_origin = $('#branch_latlng').data('longitude')

        distanceDelivery(lat_origin, lng_origin, place.geometry.location.lat(), place.geometry.location.lng())

        $('#' + klass + 'latitude').val(place.geometry.location.lat())
        $('#' + klass + 'longitude').val(place.geometry.location.lng())
        $('#'+klass+'address_concat').val(place.formatted_address)

        const communeId = $(autocomplete).data('commune-input')
        const $communeInput = $(communeId)
        const communeComponent = place.address_components.find((component) => component.types.includes('administrative_area_level_3'))
        const commune = communeComponent?.long_name
        const company_id = $(autocomplete).data('company-id')
        $communeInput.val(commune)
        $.ajax({
            url: '/price_deliveries',
            dataType: 'script',
            method: 'GET',
            data: { commune: commune, company_id: company_id }
        })

        marcador.setPosition(place.geometry.location);
        marcador.setVisible(true);
    })

}

// find me ubication
function findMe(){
    var output = document.getElementById('map');

    if(navigator.geolocation){
        output.innerHTML = "<p>Tu navegador soporta geolocalización</p>";
    }else{
        output.innerHTML = "<p>Tu navegador no soporta geolocalización</p>";
    }

    function localization(position){
        var lat = position.coords.latitude;
        var lng = position.coords.longitude;

        output.innerHTML = "<p>Latitud: " + lat + "<br>Longitud:" + lng + "</p>";
    }

    function error(){
        output.innerHTML = "<p>No se pudo obtener tu ubicación</p>";
    }

    navigator.geolocation.getCurrentPosition(localization, error);
}

function determinateNavigator(destino_lat, destino_lng){
    var userAgent = navigator.userAgent;

    // Construir la URL
    var mapsUrl;

    if (userAgent.indexOf('Android') !== -1) {
        // El usuario está en un dispositivo Android
        mapsUrl = `https://www.google.com/maps/dir/?api=1&destination=${destino_lat},${destino_lng}&dir_action=navigate`;
    }

    if (userAgent.match(/iPhone|iPod|iPad/)) {
        // El usuario está en un dispositivo iOS
        mapsUrl = `maps://maps.apple.com/?daddr=${destino_lat},${destino_lng}`;
    }

    if (!userAgent.match(/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/)) {
        // El usuario está en un navegador web
        mapsUrl = `https://www.google.com/maps/dir/?api=1&destination=${destino_lat},${destino_lng}&dir_action=navigate`;
    }

    $('#navigate-map').attr('href', mapsUrl);
}


$( document ).on('turbolinks:load', common_events);

function common_events(){

    if ($('#brewers').data('lat') && $('#brewers').data('long')){
        const coords = document.getElementById("brewers");
        const coords_branch = document.getElementById("brewers-branch");
    
        if (coords && coords_branch){
            let latitude = parseFloat(coords.getAttribute("data-lat"));
            let longitude = parseFloat(coords.getAttribute("data-long"));

            determinateNavigator(latitude, longitude);
        }
    }

    $('body').on('click', '#seeMap', function(){
        if(!$('.map-container').hasClass('active')){
            initMap();
            $('.map-container').addClass('active');
            $('.map-container').removeClass('d-none');
            $('#seeMap').html('Ocultar Mapa');
        }else{
            $('#seeMap').html('Ver mapa');
            $('.map-container').addClass('d-none');
            $('.map-container').removeClass('active');
        }
    })

    $('body').on('click', '#look-route', initMapRoute)

    let mapRoute;
    let directionsService;
    let directionsDisplay;
    let userCoords;
    let markers = [];
    let visitedLocations = [];
    const locations = [
        { type: 'branch', name: 'ricota', lat: -33.3678, lng: -70.51809999999999 },
        { type: 'branch', name: 'cotelo', lat: -33.4504928, lng: -70.6764074 },
        { type: 'branch', name: 'cotelo', lat: -33.4614399, lng: -70.55908529999999 },
        { type: 'branch', name: 'cotelo', lat: -33.4036848, lng: -70.715848 },
        { type: 'branch', name: 'cotelo', lat: -33.409935, lng: -70.571662 },
        { type: 'branch', name: 'cotelo', lat: -33.4764617, lng: -70.6617776 },
        { type: 'branch', name: 'cotelo', lat: -33.4262155, lng: -70.6026655 },
        { type: 'destiny', name: 'cliente', lat: -33.5387944, lng: -70.68356729999999 },
    ];

    function initMapRoute() {
        $('#loader').fadeIn('slow');
        mapRoute = new google.maps.Map(document.getElementById('map-route'), {
            center: userCoords,
            zoom: 12
        });

        directionsService = new google.maps.DirectionsService();
        directionsDisplay = new google.maps.DirectionsRenderer();
        directionsDisplay.setMap(mapRoute);
        getUserLocation(userLocation => {
            // Agrega la ubicación actual al inicio de la lista de ubicaciones
            locations.unshift(userLocation);
            // Calcula la ruta óptima
            const optimalRoute = calculateOptimalRoute(locations);
            // Dibuja la ruta en el mapa
            drawRoute(optimalRoute);
        });

    }

    function getUserLocation(callback) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((position) => {
                const userLocation = {
                    name: 'Ubicación Actual',
                    lat: position.coords.latitude,
                    lng: position.coords.longitude
                };
                callback(userLocation);
            }, (error) => {
                alert('No se pudo obtener la ubicación del usuario: ' + error.message);
            });
        } else {
            alert('Tu navegador no admite la geolocalización.');
        }
    }

    // Calcula la ruta óptima utilizando el algoritmo TSP
    function calculateOptimalRoute(locations) {
        // Aquí puedes implementar el algoritmo TSP que mencioné anteriormente
        // Devuelve un arreglo con las ubicaciones en el orden óptimo
        calculateTSP(locations)
        return locations;
    }

    // Dibuja la ruta en el mapa
    function drawRoute(route) {
        const waypoints = route.slice(1, -1).map(location => ({
            location: new google.maps.LatLng(location.lat, location.lng),
            stopover: true
        }));

        const request = {
            origin: new google.maps.LatLng(route[0].lat, route[0].lng),
            destination: new google.maps.LatLng(route[route.length - 1].lat, route[route.length - 1].lng),
            waypoints: waypoints,
            travelMode: 'DRIVING'
        };

        directionsService.route(request, function (result, status) {
            if (status === 'OK') {
                directionsDisplay.setDirections(result);

                // Calcula y muestra el tiempo estimado de la ruta
                const routeLegs = result.routes[0].legs;
                let totalTime = 0;
                routeLegs.forEach(leg => {
                    totalTime += leg.duration.value; // Duración en segundos
                });

                const hours = Math.floor(totalTime / 3600);
                const minutes = Math.floor((totalTime % 3600) / 60);

                $('#loader').fadeOut('slow');
                swal({title: 'Tiempo estimado en ruta', text: `Tiempo estimado de la ruta: ${hours} horas ${minutes} minutos`})
            } else {
                alert('No se pudo calcular la ruta: ' + status);
            }
        });
    }

    // necesito agrupar las solicitudes por sucursal, ya que si una dirección de entrega pertenece a una sucursal
    // muy lejana y la ruta muestra que debe entregar
    // el repartidor hará esa ruta antes de retirar el producto
    function calculateTSP(locations) {
        const n = locations.length;
        if (n <= 1) {
            return locations;
        }

        let minPath = null;
        let minDistance = Infinity;

        // Función para calcular la distancia entre dos ubicaciones
        function calculateDistance(location1, location2) {
            const lat1 = location1.lat;
            const lng1 = location1.lng;
            const lat2 = location2.lat;
            const lng2 = location2.lng;

            const radlat1 = Math.PI * lat1 / 180;
            const radlat2 = Math.PI * lat2 / 180;
            const theta = lng1 - lng2;
            const radtheta = Math.PI * theta / 180;

            let dist = Math.sin(radlat1) * Math.sin(radlat2) + Math.cos(radlat1) * Math.cos(radlat2) * Math.cos(radtheta);
            dist = Math.acos(dist);
            dist = dist * 180 / Math.PI;
            dist = dist * 60 * 1.1515; // En millas
            dist = dist * 1.609344; // En kilómetros
            return dist;
        }

        // Función para calcular la distancia total de una ruta
        function calculateTotalDistance(route) {
            let totalDistance = 0;
            for (let i = 0; i < route.length - 1; i++) {
                totalDistance += calculateDistance(route[i], route[i + 1]);
            }
            return totalDistance;
        }

        // Función para generar todas las permutaciones de un arreglo
        function generatePermutations(arr) {
            if (arr.length === 0) {
                return [[]];
            }

            const firstElem = arr[0];
            const restArr = arr.slice(1);
            const restPermutations = generatePermutations(restArr);

            const allPermutations = [];
            for (const perm of restPermutations) {
                for (let i = 0; i <= perm.length; i++) {
                    const newPerm = perm.slice();
                    newPerm.splice(i, 0, firstElem);
                    allPermutations.push(newPerm);
                }
            }

            return allPermutations;
        }

        // Genera todas las permutaciones de las ubicaciones
        const allPermutations = generatePermutations(locations);

        // Encuentra la ruta más corta
        for (const perm of allPermutations) {
            const distance = calculateTotalDistance(perm);
            if (distance < minDistance) {
                minDistance = distance;
                minPath = perm;
            }
        }

        return minPath;
    }
}

window.initMap = initMap;
window.launchmap = launchmap;

// Driver Positions Map
let driverPositionsMap;
let driverMarkers = [];
let destinationMarkers = [];
let fetchIntervalId;
let allPositions = []; // Para almacenar todas las posiciones
let selectedUserId = null; // Para filtrar por usuario
let autoUpdateEnabled = true; // Para controlar la actualización automática

// Funciones para crear iconos personalizados
function createTruckIcon() {
    return {
        url: '/packs/images/icon_driver.png',
        scaledSize: new google.maps.Size(32, 32),
        anchor: new google.maps.Point(16, 16)
    };
}

function createDestinationIcon() {
    return {
        url: '/packs/images/icon_gift.png',
        scaledSize: new google.maps.Size(32, 32),
        anchor: new google.maps.Point(16, 16)
    };
}

function initDriverPositionsMap() {
    if (!document.getElementById('map-driver-positions')) return;
    
    driverPositionsMap = new google.maps.Map(document.getElementById('map-driver-positions'), {
        zoom: 12,
        center: { lat: -33.45, lng: -70.6667 }, // Santiago, Chile
        mapId: "8ccbea4ce4308a7b",
        disableDefaultUI: true,
        mapTypeControl: false
    });
    
    fetchDriverPositions();
    startAutoUpdate();
}

function startAutoUpdate() {
    if (fetchIntervalId) clearInterval(fetchIntervalId);
    if (autoUpdateEnabled) {
        fetchIntervalId = setInterval(fetchDriverPositions, 15000);
    }
}

function stopAutoUpdate() {
    if (fetchIntervalId) {
        clearInterval(fetchIntervalId);
        fetchIntervalId = null;
    }
}

function toggleAutoUpdate() {
    autoUpdateEnabled = !autoUpdateEnabled;
    const button = $('#toggle-auto-update');
    
    if (autoUpdateEnabled) {
        startAutoUpdate();
        button.removeClass('btn-warning').addClass('btn-success');
        button.html('<i class="fas fa-pause"></i> Pausar');
    } else {
        stopAutoUpdate();
        button.removeClass('btn-success').addClass('btn-warning');
        button.html('<i class="fas fa-play"></i> Reanudar');
    }
}

function adjustMapToMarkers() {
    if (!driverPositionsMap || !allPositions.length) return;
    
    let positionsToShow = allPositions;
    if (selectedUserId && selectedUserId !== 'all') {
        const userIdNum = parseInt(selectedUserId);
        positionsToShow = allPositions.filter(pos => pos.user.id === userIdNum);
    }
    
    if (positionsToShow.length === 1) {
        const pos = positionsToShow[0];
        const bounds = new google.maps.LatLngBounds();
        
        // Agregar ubicación del conductor
        bounds.extend({ lat: pos.latitude, lng: pos.longitude });
        
        // Agregar destino si existe
        if (pos.destination_latitude && pos.destination_longitude) {
            bounds.extend({ lat: pos.destination_latitude, lng: pos.destination_longitude });
        }
        
        driverPositionsMap.fitBounds(bounds);
        driverPositionsMap.setZoom(Math.min(driverPositionsMap.getZoom(), 14));
    } else if (positionsToShow.length > 1) {
        // Ajustar el mapa para mostrar todos los marcadores visibles
        const bounds = new google.maps.LatLngBounds();
        positionsToShow.forEach(pos => {
            bounds.extend({ lat: pos.latitude, lng: pos.longitude });
            if (pos.destination_latitude && pos.destination_longitude) {
                bounds.extend({ lat: pos.destination_latitude, lng: pos.destination_longitude });
            }
        });
        driverPositionsMap.fitBounds(bounds);
    }
}

function clearDriverMarkers() {
    driverMarkers.forEach(m => m.setMap(null));
    driverMarkers = [];
    destinationMarkers.forEach(m => m.setMap(null));
    destinationMarkers = [];
}

function addDriverMarkers(positions) {
    positions.forEach(function(pos) {
        // Marcador del conductor con información detallada
        const driverInfo = `
            <div style="padding: 10px;">
                <h6 style="margin: 0; color: #333;">${pos.user.name}</h6>
                <p style="margin: 5px 0; font-size: 12px; color: #666;">
                    <strong>Ubicación actual:</strong><br>
                    Lat: ${pos.latitude.toFixed(6)}<br>
                    Lng: ${pos.longitude.toFixed(6)}
                </p>
                ${pos.destination_latitude && pos.destination_longitude ? 
                    `<p style="margin: 5px 0; font-size: 12px; color: #0066cc;">
                        <strong>Destino:</strong><br>
                        Lat: ${pos.destination_latitude.toFixed(6)}<br>
                        Lng: ${pos.destination_longitude.toFixed(6)}
                    </p>` : 
                    '<p style="margin: 5px 0; font-size: 12px; color: #999;">Sin destino asignado</p>'
                }
                <p style="margin: 5px 0; font-size: 11px; color: #888;">
                    Última actualización: ${formatTime(pos.updated_at)}
                </p>
            </div>
        `;
        
        const infoWindow = new google.maps.InfoWindow({
            content: driverInfo
        });
        
        const marker = new google.maps.Marker({
            position: { lat: pos.latitude, lng: pos.longitude },
            map: driverPositionsMap,
            label: {
                text: pos.user.name,
                className: 'driver-label'
            },
            title: `${pos.user.name} - Ubicación actual`,
            icon: createTruckIcon()
        });
        
        // Evento click para mostrar información
        marker.addListener('click', function() {
            infoWindow.open(driverPositionsMap, marker);
        });
        
        driverMarkers.push(marker);

        // Marcador de destino (si existe)
        if (pos.destination_latitude && pos.destination_longitude) {
            const destinationInfo = `
                <div style="padding: 10px;">
                    <h6 style="margin: 0; color: #0066cc;">Destino de ${pos.user.name}</h6>
                    <p style="margin: 5px 0; font-size: 12px; color: #666;">
                        <strong>Coordenadas:</strong><br>
                        Lat: ${pos.destination_latitude.toFixed(6)}<br>
                        Lng: ${pos.destination_longitude.toFixed(6)}
                    </p>
                    <p style="margin: 5px 0; font-size: 11px; color: #888;">
                        Conductor: ${pos.user.name}
                    </p>
                </div>
            `;
            
            const destInfoWindow = new google.maps.InfoWindow({
                content: destinationInfo
            });
            
            const destMarker = new google.maps.Marker({
                position: { lat: pos.destination_latitude, lng: pos.destination_longitude },
                map: driverPositionsMap,
                icon: createDestinationIcon(),
                label: {
                    text: `Destino de ${pos.user.name}`,
                    className: 'destination-label'
                },
                title: `Destino de ${pos.user.name}`
            });
            
            // Evento click para mostrar información del destino
            destMarker.addListener('click', function() {
                destInfoWindow.open(driverPositionsMap, destMarker);
            });
            
            destinationMarkers.push(destMarker);
        }
    });
}

function updateUsersList(positions) {
    const usersList = $('#users-list');
    usersList.empty();
    
    if (!positions || positions.length === 0) {
        usersList.append(`
            <div class="list-group-item text-center text-muted">
                <i class="fas fa-info-circle mb-2"></i>
                <br>No hay conductores activos
            </div>
        `);
        return;
    }
    
    // Agregar opción "Todos los usuarios"
    const allUsersItem = $(`
        <div class="list-group-item list-group-item-action d-flex justify-content-between align-items-center ${selectedUserId === null ? 'active' : ''}" 
             data-user-id="all">
            <div>
                <strong>Todos los usuarios</strong>
                <br><small class="text-muted">${positions.length} conductores activos</small>
            </div>
            <span class="badge bg-primary rounded-pill">${positions.length}</span>
        </div>
    `);
    usersList.append(allUsersItem);
    
    // Agregar cada usuario
    positions.forEach(function(pos) {
        const userItem = $(`
            <div class="list-group-item list-group-item-action d-flex justify-content-between align-items-center ${selectedUserId === pos.user.id ? 'active' : ''}" 
                 data-user-id="${pos.user.id}">
                <div>
                    <strong>${pos.user.name}</strong>
                    <br><small class="text-muted">Última actualización: ${formatTime(pos.updated_at)}</small>
                </div>
                <span class="badge bg-success rounded-pill">Activo</span>
            </div>
        `);
        usersList.append(userItem);
    });
    
    // Event listeners para los items
    usersList.find('.list-group-item').click(function() {
        const userId = $(this).data('user-id');
        filterByUser(userId);
    });
}

function filterByUser(userId) {
    selectedUserId = userId === 'all' ? null : userId;
    
    // Actualizar clases activas
    $('#users-list .list-group-item').removeClass('active');
    $(`[data-user-id="${userId}"]`).addClass('active');
    
    // Filtrar marcadores
    clearDriverMarkers();
    
    let positionsToShow = allPositions;
    if (selectedUserId && selectedUserId !== 'all') {
        // Convertir a número para comparación correcta
        const userIdNum = parseInt(selectedUserId);
        positionsToShow = allPositions.filter(pos => pos.user.id === userIdNum);
    }
    
    // Agregar marcadores con información detallada
    positionsToShow.forEach(function(pos) {
        // Marcador del conductor con información detallada
        const driverInfo = `
            <div style="padding: 10px;">
                <h6 style="margin: 0; color: #333;">${pos.user.name}</h6>
                <p style="margin: 5px 0; font-size: 12px; color: #666;">
                    <strong>Ubicación actual:</strong><br>
                    Lat: ${pos.latitude.toFixed(6)}<br>
                    Lng: ${pos.longitude.toFixed(6)}
                </p>
                ${pos.destination_latitude && pos.destination_longitude ? 
                    `<p style="margin: 5px 0; font-size: 12px; color: #0066cc;">
                        <strong>Destino:</strong><br>
                        Lat: ${pos.destination_latitude.toFixed(6)}<br>
                        Lng: ${pos.destination_longitude.toFixed(6)}
                    </p>` : 
                    '<p style="margin: 5px 0; font-size: 12px; color: #999;">Sin destino asignado</p>'
                }
                <p style="margin: 5px 0; font-size: 11px; color: #888;">
                    Última actualización: ${formatTime(pos.updated_at)}
                </p>
            </div>
        `;
        
        const infoWindow = new google.maps.InfoWindow({
            content: driverInfo
        });
        
        const marker = new google.maps.Marker({
            position: { lat: pos.latitude, lng: pos.longitude },
            map: driverPositionsMap,
            label: {
                text: pos.user.name,
                className: 'driver-label'
            },
            title: `${pos.user.name} - Ubicación actual`,
            icon: createTruckIcon()
        });
        
        // Evento click para mostrar información
        marker.addListener('click', function() {
            infoWindow.open(driverPositionsMap, marker);
        });
        
        driverMarkers.push(marker);

        // Marcador de destino (si existe)
        if (pos.destination_latitude && pos.destination_longitude) {
            const destinationInfo = `
                <div style="padding: 10px;">
                    <h6 style="margin: 0; color: #0066cc;">Destino de ${pos.user.name}</h6>
                    <p style="margin: 5px 0; font-size: 12px; color: #666;">
                        <strong>Coordenadas:</strong><br>
                        Lat: ${pos.destination_latitude.toFixed(6)}<br>
                        Lng: ${pos.destination_longitude.toFixed(6)}
                    </p>
                    <p style="margin: 5px 0; font-size: 11px; color: #888;">
                        Conductor: ${pos.user.name}
                    </p>
                </div>
            `;
            
            const destInfoWindow = new google.maps.InfoWindow({
                content: destinationInfo
            });
            
            const destMarker = new google.maps.Marker({
                position: { lat: pos.destination_latitude, lng: pos.destination_longitude },
                map: driverPositionsMap,
                icon: createDestinationIcon(),
                label: {
                    text: `Destino de ${pos.user.name}`,
                    className: 'destination-label'
                },
                title: `Destino de ${pos.user.name}`
            });
            
            // Evento click para mostrar información del destino
            destMarker.addListener('click', function() {
                destInfoWindow.open(driverPositionsMap, destMarker);
            });
            
            destinationMarkers.push(destMarker);
        }
    });
    
    // Solo ajustar el mapa si es la primera carga o si el usuario lo solicita explícitamente
    // No ajustar automáticamente durante las actualizaciones
}

function formatTime(timestamp) {
    const date = new Date(timestamp);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    
    if (diffMins < 1) return 'Ahora mismo';
    if (diffMins < 60) return `Hace ${diffMins} min`;
    
    const diffHours = Math.floor(diffMins / 60);
    if (diffHours < 24) return `Hace ${diffHours}h`;
    
    const diffDays = Math.floor(diffHours / 24);
    return `Hace ${diffDays}d`;
}

function fetchDriverPositions() {
    const url = $('#map-driver-positions').data('positions-url');
    if (!url) return;
    
    $.ajax({
        url: url,
        type: 'GET',
        dataType: 'json',
        headers: {
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
        },
        success: function(data) {
            allPositions = data; // Almacenar todas las posiciones
            updateUsersList(data); // Actualizar la lista de usuarios
            
            // Mostrar/ocultar mensaje de no hay ubicaciones
            if (!data || data.length === 0) {
                $('#no-positions-message').show();
                $('#map-driver-positions').hide();
            } else {
                $('#no-positions-message').hide();
                $('#map-driver-positions').show();
                
                // Aplicar filtro actual si existe
                if (selectedUserId) {
                    filterByUser(selectedUserId);
                } else {
                    clearDriverMarkers();
                    addDriverMarkers(data);
                }
            }
        },
        error: function(xhr, status, error) {
            console.error('Error fetching driver positions:', error);
            // En caso de error, mostrar mensaje
            $('#no-positions-message').show();
            $('#map-driver-positions').hide();
        }
    });
}

// Add to common_events function
$(document).on('turbolinks:load', function() {
    common_events();
    
    // Initialize driver positions map if element exists
    if ($('#map-driver-positions').length > 0) {
        initDriverPositionsMap();
        
        // Set up event listeners after map initialization
        setTimeout(function() {
            // Manual refresh button
            $('#refresh-map').off('click').on('click', fetchDriverPositions);
            
            // Toggle auto update button
            $('#toggle-auto-update').off('click').on('click', toggleAutoUpdate);
            
            // Adjust map button
            $('#adjust-map').off('click').on('click', adjustMapToMarkers);
        }, 1000);
    }
});

// Make functions globally available
window.initDriverPositionsMap = initDriverPositionsMap;
window.fetchDriverPositions = fetchDriverPositions;
window.toggleAutoUpdate = toggleAutoUpdate;
window.adjustMapToMarkers = adjustMapToMarkers; 