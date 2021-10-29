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
import { navbar } from '../components/navbar';
import { checkoutForm } from '../components/checkout_form';
import { addressForm } from '../components/address_form';
import { priceRangeSlider } from '../components/price_range_slider';
import { productShowVariants } from '../components/product_show_variants';
import { cartForm } from '../components/cart_form';
import { productShowAtcBtn } from '../components/product_show_atc_btn';
import { productSorting } from '../components/product_sorting';
import { productFiltersModal } from '../components/product_filters_modal';
import { productFilters } from '../components/product_filters';
import { cart } from '../components/cart';

// Internal Plugins
import { initMapbox } from '../plugins/init_mapbox';
import { initBacCheckout } from '../plugins/bac_checkout';

// Call your functions here
document.addEventListener('turbolinks:load', () => {
  navbar();
  checkoutForm();
  addressForm();
  priceRangeSlider();
  productShowVariants();
  cartForm();
  productShowAtcBtn();
  productSorting();
  productFiltersModal();
  productFilters();
  cart();

  initMapbox();
  initBacCheckout();
});
