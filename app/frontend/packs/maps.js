

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
