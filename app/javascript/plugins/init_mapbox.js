// Importing mapbox-gl with a bang (!mapbox-gl) exclude mapbox-gl from being transpiled by webpack
import mapboxgl from '!mapbox-gl';
import 'mapbox-gl/dist/mapbox-gl.css';

const initMapbox = () => {
  const mapElement = document.getElementById('map');

  // Shown on the address page when defining shipping address
  if (mapElement) {
    // Get latitude and longitude hidden inputs
    const latitudeInput = document.getElementById('order_ship_address_attributes_latitude');
    const longitudeInput = document.getElementById('order_ship_address_attributes_longitude');

    // Method that update the value of latitude and longitude hidden inputs
    const updateCoordinates = () => {
      latitudeInput.value = marker.getLngLat().lat;
      longitudeInput.value = marker.getLngLat().lng;
    };

    // initialize a mapbox map in the center of Panama
    mapboxgl.accessToken = gon.mapbox_api_key;
    const map = new mapboxgl.Map({
      container: 'map', // container ID
      style: 'mapbox://styles/mapbox/streets-v11', // style URL
      center: [-79.528142, 8.975448], // starting position [lng, lat]
      zoom: 15 // starting zoom
    });

    // Create a new draggable market on the map, and put it by default in the center of Panama
    const marker = new mapboxgl.Marker({
      draggable: true
    })
        .setLngLat([-79.528142, 8.975448])
        .addTo(map);

    // Every time the marker is dragged, call updateCoordinates method
    marker.on('dragend', updateCoordinates);

    // Add en event listener on the area (corregimiento) input
    // and update the map each time it changes
    const corregimientoInput = document.getElementById('order_ship_address_attributes_district_id');
    corregimientoInput.addEventListener('change', (event) => {
      const indexOfSelectedDistrict = corregimientoInput.options.selectedIndex;
      const latitude = parseFloat(corregimientoInput.options[indexOfSelectedDistrict].dataset.latitude);
      const longitude = parseFloat(corregimientoInput.options[indexOfSelectedDistrict].dataset.longitude);
      // Then we need to do 3 things :
      // - put the marker on the center of the selected area
      // - resize the map
      // - put the center of the map on the selected area
      marker.setLngLat([longitude, latitude]);
      map.resize();
      map.flyTo({ center: [longitude, latitude] });
      latitudeInput.value = longitudeInput.value = null;
    });


    // Prevent form submission if map marker have not been set
    const submitAddressBtn = document.querySelector('#checkout_form_address input[type=submit]');
    submitAddressBtn.addEventListener('click', (event) => {
      if (!latitudeInput.value || !longitudeInput.value) {
        event.preventDefault();
        document.getElementById('missing-map-pin').style.color = '#FD1015';
        mapElement.style.border = '1px solid red';
      }
    });
  }

  const staticMapElement = document.getElementById('static-map');

  // Shown on the confirmation page when displaying the shipping address
  if (staticMapElement) {
    const { latitude, longitude } = staticMapElement.dataset;
    // initialize a mapbox map with shipping address coordinate
    mapboxgl.accessToken = gon.mapbox_api_key;
    const map = new mapboxgl.Map({
      container: 'static-map', // container ID
      style: 'mapbox://styles/mapbox/streets-v11', // style URL
      center: [longitude, latitude], // starting position [lng, lat]
      zoom: 15 // starting zoom
    });

    new mapboxgl.Marker()
        .setLngLat([longitude, latitude])
        .addTo(map);
  }
};

export { initMapbox };
