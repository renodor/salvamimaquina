import { Controller } from '@hotwired/stimulus'
import mapboxgl from 'mapbox-gl'

export default class extends Controller {
  static values = {
    latitude: Number,
    longitude: Number
  }

  connect() {
    // Shown on the confirmation page when displaying the shipping address

    // initialize a mapbox map with shipping address coordinate
    mapboxgl.accessToken = gon.mapbox_api_key;
    this.map = new mapboxgl.Map({
      container: 'static-map', // container ID
      style: 'mapbox://styles/mapbox/streets-v11', // style URL
      center: [this.longitudeValue, this.latitudeValue], // starting position [lng, lat]
      zoom: 15 // starting zoom
    });

    new mapboxgl.Marker()
    .setLngLat([this.longitudeValue, this.latitudeValue])
    .addTo(this.map);
  }
}
