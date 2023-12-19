import { Controller } from '@hotwired/stimulus'
import mapboxgl from 'mapbox-gl'

export default class extends Controller {
  static targets = ['map', 'latitude', 'longitude']

  connect() {
    // Shown on the address page when defining shipping address

    // initialize a mapbox map in the center of Panama City
    mapboxgl.accessToken = gon.mapbox_api_key;
    this.map = new mapboxgl.Map({
      container: 'map', // container ID
      style: 'mapbox://styles/mapbox/streets-v11', // style URL
      center: [-79.528142, 8.975448], // starting position [lng, lat]
      zoom: 15 // starting zoom
    });

    // Create a new draggable market on the map, and put it by default in the center of Panama
    this.marker = new mapboxgl.Marker({
      draggable: true
    })
        .setLngLat([-79.528142, 8.975448])
        .addTo(this.map);

    // Every time the marker is dragged, call updateCoordinates method
    this.marker.on('dragend', () => {
      this.latitudeTarget.value = this.marker.getLngLat().lat;
      this.longitudeTarget.value = this.marker.getLngLat().lng;
    });

    // When loading the page, call updateMap() if a point on the map has already been defined
    // (It happens if user select a point on the map, validates, and then comes back to the page)
    if (this.latitudeTarget.value && this.longitudeTarget.value) {
      this.updateMap(this.latitudeTarget.value, this.longitudeTarget.value);
    }

    // Add en event listener on the area (corregimiento) input
    // and update the map each time it changes
    // + Nullify latitude and longitude hidden fields value, to be sure user will move the marker
    const corregimientoInput = document.querySelector('[data-input="district_id"]');
    corregimientoInput.addEventListener('change', (event) => {
      const indexOfSelectedDistrict = corregimientoInput.options.selectedIndex;
      const latitude = parseFloat(corregimientoInput.options[indexOfSelectedDistrict].dataset.latitude);
      const longitude = parseFloat(corregimientoInput.options[indexOfSelectedDistrict].dataset.longitude);
      this.updateMap(latitude, longitude);
      this.latitudeTarget.value = null;
      this.longitudeTarget.value = null;
    });


    // Prevent form submission if map marker have not been set
    const submitAddressBtn = document.querySelector('input[type=submit][data-input="map_submit"]');
    submitAddressBtn.addEventListener('click', (event) => {
      if (!this.latitudeTarget.value || !this.longitudeTarget.value) {
        event.preventDefault();
        document.getElementById('missing-map-pin').style.color = '#FD1015';
        this.mapTarget.style.border = '1px solid red';
      }
    });
  }

  // Update the displayed map by doing 3 things:
  // - puting the marker on the center of the selected area
  // - resizing the map
  // - puting the center of the map on the selected area
  updateMap(latitude, longitude) {
    this.marker.setLngLat([longitude, latitude]);
    this.map.resize();
    this.map.flyTo({ center: [longitude, latitude] });
  };

  // const staticMapElement = document.getElementById('static-map');

  // // Shown on the confirmation page when displaying the shipping address
  // if (staticMapElement) {
  //   const { latitude, longitude } = staticMapElement.dataset;
  //   // initialize a mapbox map with shipping address coordinate
  //   mapboxgl.accessToken = gon.mapbox_api_key;
  //   const map = new mapboxgl.Map({
  //     container: 'static-map', // container ID
  //     style: 'mapbox://styles/mapbox/streets-v11', // style URL
  //     center: [longitude, latitude], // starting position [lng, lat]
  //     zoom: 15 // starting zoom
  //   });

  //   new mapboxgl.Marker()
  //       .setLngLat([longitude, latitude])
  //       .addTo(map);
  // }
}
