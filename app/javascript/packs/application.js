// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// require("@rails/ujs").start()
require('turbolinks').start();
require('@rails/activestorage').start();
require('channels');


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Packages
import 'bootstrap';

// Internal Components
import { addressForm } from '../components/address_form';
import { priceRangeSlider } from '../components/price_range_slider';
import { productShowCartForm } from '../components/product_show_cart_form';
import { productFilter } from '../components/product_filter';

// Internal Plugins
import { initMapbox } from '../plugins/init_mapbox';
import { initBacCheckout } from '../plugins/bac_checkout';

// Call your functions here
document.addEventListener('turbolinks:load', () => {
  addressForm();
  priceRangeSlider();
  productShowCartForm();
  productFilter();

  initMapbox();
  initBacCheckout();
});
