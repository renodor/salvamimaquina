(self["webpackChunksalvamimaquina"] = self["webpackChunksalvamimaquina"] || []).push([["application"],{

/***/ "./app/javascript/channels sync recursive _channel\\.js$":
/*!*****************************************************!*\
  !*** ./app/javascript/channels/ sync _channel\.js$ ***!
  \*****************************************************/
/***/ (function(module) {

function webpackEmptyContext(req) {
	var e = new Error("Cannot find module '" + req + "'");
	e.code = 'MODULE_NOT_FOUND';
	throw e;
}
webpackEmptyContext.keys = function() { return []; };
webpackEmptyContext.resolve = webpackEmptyContext;
webpackEmptyContext.id = "./app/javascript/channels sync recursive _channel\\.js$";
module.exports = webpackEmptyContext;

/***/ }),

/***/ "./app/javascript/application.js":
/*!***************************************!*\
  !*** ./app/javascript/application.js ***!
  \***************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var bootstrap__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! bootstrap */ "./node_modules/bootstrap/dist/js/bootstrap.esm.js");
/* harmony import */ var _components_navbar__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./components/navbar */ "./app/javascript/components/navbar.js");
/* harmony import */ var _components_flash__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./components/flash */ "./app/javascript/components/flash.js");
/* harmony import */ var _components_checkout_form__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./components/checkout_form */ "./app/javascript/components/checkout_form.js");
/* harmony import */ var _components_price_range_slider__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./components/price_range_slider */ "./app/javascript/components/price_range_slider.js");
/* harmony import */ var _components_product_show_variants__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./components/product_show_variants */ "./app/javascript/components/product_show_variants.js");
/* harmony import */ var _components_product_show_thumbnails__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./components/product_show_thumbnails */ "./app/javascript/components/product_show_thumbnails.js");
/* harmony import */ var _components_products_sidebar__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./components/products_sidebar */ "./app/javascript/components/products_sidebar.js");
/* harmony import */ var _components_products_filters_form__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./components/products_filters_form */ "./app/javascript/components/products_filters_form.js");
/* harmony import */ var _components_products_sorting__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! ./components/products_sorting */ "./app/javascript/components/products_sorting.js");
/* harmony import */ var _components_products_search__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ./components/products_search */ "./app/javascript/components/products_search.js");
/* harmony import */ var _components_quantity_selector__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./components/quantity_selector */ "./app/javascript/components/quantity_selector.js");
/* harmony import */ var _components_add_to_cart__WEBPACK_IMPORTED_MODULE_12__ = __webpack_require__(/*! ./components/add_to_cart */ "./app/javascript/components/add_to_cart.js");
/* harmony import */ var _components_cart__WEBPACK_IMPORTED_MODULE_13__ = __webpack_require__(/*! ./components/cart */ "./app/javascript/components/cart.js");
/* harmony import */ var _components_preview_image_on_file_select__WEBPACK_IMPORTED_MODULE_14__ = __webpack_require__(/*! ./components/preview_image_on_file_select */ "./app/javascript/components/preview_image_on_file_select.js");
/* harmony import */ var _components_trade_in_form__WEBPACK_IMPORTED_MODULE_15__ = __webpack_require__(/*! ./components/trade_in_form */ "./app/javascript/components/trade_in_form.js");
/* harmony import */ var _plugins_swiper_slider__WEBPACK_IMPORTED_MODULE_16__ = __webpack_require__(/*! ./plugins/swiper_slider */ "./app/javascript/plugins/swiper_slider.js");
/* harmony import */ var _plugins_init_mapbox__WEBPACK_IMPORTED_MODULE_17__ = __webpack_require__(/*! ./plugins/init_mapbox */ "./app/javascript/plugins/init_mapbox.js");
// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// require("@rails/ujs").start()
(__webpack_require__(/*! turbolinks */ "./node_modules/turbolinks/dist/turbolinks.js").start)();
(__webpack_require__(/*! @rails/activestorage */ "./node_modules/@rails/activestorage/app/assets/javascripts/activestorage.js").start)();
__webpack_require__(/*! channels */ "./app/javascript/channels/index.js");

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

// Packages


// Internal Components



// import { addressForm } from './components/address_form';













// Internal Plugins



// Call your functions here
document.addEventListener('turbolinks:load', () => {
  (0,_components_navbar__WEBPACK_IMPORTED_MODULE_1__.navbar)();
  (0,_components_flash__WEBPACK_IMPORTED_MODULE_2__.addDinamysmToFlash)();
  (0,_components_checkout_form__WEBPACK_IMPORTED_MODULE_3__.checkoutForm)();
  // addressForm();
  (0,_components_price_range_slider__WEBPACK_IMPORTED_MODULE_4__.priceRangeSlider)();
  (0,_components_product_show_variants__WEBPACK_IMPORTED_MODULE_5__.productShowVariants)();
  (0,_components_product_show_thumbnails__WEBPACK_IMPORTED_MODULE_6__.productShowThumbnails)();
  (0,_components_products_sidebar__WEBPACK_IMPORTED_MODULE_7__.productsSidebar)();
  (0,_components_products_filters_form__WEBPACK_IMPORTED_MODULE_8__.productsFiltersForm)();
  (0,_components_products_sorting__WEBPACK_IMPORTED_MODULE_9__.productsSorting)();
  (0,_components_products_search__WEBPACK_IMPORTED_MODULE_10__.productsSearch)();
  (0,_components_quantity_selector__WEBPACK_IMPORTED_MODULE_11__.quantitySelector)();
  (0,_components_add_to_cart__WEBPACK_IMPORTED_MODULE_12__.addToCart)();
  (0,_components_cart__WEBPACK_IMPORTED_MODULE_13__.cart)();
  (0,_components_preview_image_on_file_select__WEBPACK_IMPORTED_MODULE_14__.previewImageOnFileSelect)();
  (0,_components_trade_in_form__WEBPACK_IMPORTED_MODULE_15__.tradeInForm)();
  (0,_plugins_init_mapbox__WEBPACK_IMPORTED_MODULE_17__.initMapbox)();
  (0,_plugins_swiper_slider__WEBPACK_IMPORTED_MODULE_16__.swiperSlider)();
});

/***/ }),

/***/ "./app/javascript/channels/index.js":
/*!******************************************!*\
  !*** ./app/javascript/channels/index.js ***!
  \******************************************/
/***/ (function(__unused_webpack_module, __unused_webpack_exports, __webpack_require__) {

// Load all the channels within this directory and all subdirectories.
// Channel files must be named *_channel.js.

const channels = __webpack_require__("./app/javascript/channels sync recursive _channel\\.js$");
channels.keys().forEach(channels);

/***/ }),

/***/ "./app/javascript/components/add_to_cart.js":
/*!**************************************************!*\
  !*** ./app/javascript/components/add_to_cart.js ***!
  \**************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   addToCart: function() { return /* binding */ addToCart; }
/* harmony export */ });
/* harmony import */ var _flash__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./flash */ "./app/javascript/components/flash.js");
// Update front end when a variant has been added to cart (via Ajax)

const addToCart = () => {
  const cartForm = document.querySelector('#cart-form form');
  if (cartForm) {
    window.Modal = __webpack_require__(/*! bootstrap/js/dist/modal */ "./node_modules/bootstrap/js/dist/modal.js");

    // Listen on cart form ajax:success event (when a variant has successfully been added to cart), and:
    // - update the navbar cart counter
    // - display the add to cart modal with the variant name
    cartForm.addEventListener('ajax:success', event => {
      const payload = event.detail[0];
      const cartQuantityTag = document.querySelector('#navbar-icons .navbar-cart-quantity');
      if (cartQuantityTag) {
        const newCartQuantity = parseInt(cartQuantityTag.innerHTML) + payload.quantity;
        cartQuantityTag.innerHTML = newCartQuantity;
        cartQuantityTag.classList.remove('display-none');
      }
      const addToCartModal = document.getElementById('addToCartModal');
      addToCartModal.querySelector('.modal-body #variant-name').innerHTML = payload.variantName;
      new Modal(addToCartModal).show();
    });

    // Listen on cart form ajax:error event (when there is an error trying to add a product to cart), and:
    // - display a flash error message
    cartForm.addEventListener('ajax:error', event => (0,_flash__WEBPACK_IMPORTED_MODULE_0__.addFlashToDom)(event.detail[0].flash));
  }
};


/***/ }),

/***/ "./app/javascript/components/cart.js":
/*!*******************************************!*\
  !*** ./app/javascript/components/cart.js ***!
  \*******************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   cart: function() { return /* binding */ cart; }
/* harmony export */ });
const cart = () => {
  const cart = document.getElementById('cart-detail');
  if (cart) {
    //   const lineItems = cart.querySelectorAll('.line-item');
    //   lineItems.forEach((lineItem) => {
    //     const lineItemId = lineItem.dataset.id;
    //     const cartItemDelete = lineItem.querySelector('.cart-item-delete');
    //     cartItemDelete.addEventListener('click', (event) => {
    //       fetch(`api/orders/${gon.order_info.number}/line_items/${lineItemId}`, {
    //         method: 'DELETE',
    //         headers: {
    //           'X-Spree-Order-Token': gon.order_info.guest_token,
    //           'accept': 'application/json'
    //         }
    //       })
    //         .then((response) => response.json())
    //         .then(({ lineItem }) => {
    //           removeLineItem(lineItem.id);
    //           updateOrderInfo()
    //         });
    //     })
    //   })

    //   const removeLineItem = (id) => {
    //     cart.querySelector(`.line-item[data-id="${id}"]`).remove()
    //   }

    //   const updateOrderInfo = () => {
    //     fetch(`api/orders/${gon.order_info.number}`, {
    //       headers: {
    //         'X-Spree-Order-Token': gon.order_info.guest_token,
    //         'accept': 'application/json'
    //       }
    //     })
    //       .then((response) => response.json())
    //       .then((data) => {
    //         debugger
    //       });
    //   }
  }
};


/***/ }),

/***/ "./app/javascript/components/checkout_form.js":
/*!****************************************************!*\
  !*** ./app/javascript/components/checkout_form.js ***!
  \****************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   checkoutForm: function() { return /* binding */ checkoutForm; }
/* harmony export */ });
const checkoutForm = () => {
  const checkout = document.getElementById('checkout');
  if (checkout) {
    const inputs = checkout.querySelectorAll('input, select, textarea');
    inputs.forEach(input => {
      input.addEventListener('invalid', event => {
        input.classList.add('error');
      });
      input.addEventListener('blur', event => {
        if (input.checkValidity()) {
          input.classList.remove('error');
        }
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/flash.js":
/*!********************************************!*\
  !*** ./app/javascript/components/flash.js ***!
  \********************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   addDinamysmToFlash: function() { return /* binding */ addDinamysmToFlash; },
/* harmony export */   addFlashToDom: function() { return /* binding */ addFlashToDom; }
/* harmony export */ });
// Add the given flash (html tag as a string) to the DOM, and then add dynamism to it
// This method is a bit special, indeed instead of being imported in application.js,
// it is imported in other modules when we need to add a flash after an ajax request (ex: add_to_cart.js)
const addFlashToDom = flash => {
  const content = document.querySelector('body #wrapper #content');
  content.insertAdjacentHTML('afterbegin', flash);
  addDinamysmToFlash();
};

// Remove flash when clicking on cross and auto remove it after 10 seconds
// (is imported in application.js, so it will be called automatically when page load,
// and is also called by addFlashToDom() when needed)
const addDinamysmToFlash = () => {
  const flash = document.querySelector('.flash');
  if (flash) {
    flash.querySelector('svg.close-flash').addEventListener('click', () => flash.remove());
    setTimeout(() => {
      flash.remove();
    }, 10000);
  }
};


/***/ }),

/***/ "./app/javascript/components/navbar.js":
/*!*********************************************!*\
  !*** ./app/javascript/components/navbar.js ***!
  \*********************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   navbar: function() { return /* binding */ navbar; }
/* harmony export */ });
// method to open/close the navbar on mobile
const navbar = () => {
  const navbarTogglers = document.querySelectorAll('.navbar-toggler');
  const navbarCollapse = document.querySelector('.navbar-collapse');
  const body = document.querySelector('body');

  // listen clicks on the navbar toggle and open the navbar when clicked
  navbarTogglers.forEach(navbarToggler => {
    navbarToggler.addEventListener('click', () => {
      if (navbarCollapse.classList.contains('active')) {
        navbarCollapse.classList.remove('active');
        document.querySelector('.content-overlay').remove();
        body.classList.remove('overflow-hidden', 'position-relative');
      } else {
        body.classList.add('overflow-hidden', 'position-relative');
        const contentOverlay = document.createElement('div');
        contentOverlay.classList.add('content-overlay');
        body.appendChild(contentOverlay);
        navbarCollapse.classList.add('active');
      }
    });
  });
};


/***/ }),

/***/ "./app/javascript/components/preview_image_on_file_select.js":
/*!*******************************************************************!*\
  !*** ./app/javascript/components/preview_image_on_file_select.js ***!
  \*******************************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   previewImageOnFileSelect: function() { return /* binding */ previewImageOnFileSelect; }
/* harmony export */ });
// When uploading an image to a form, display a preview of it next to the form input
const previewImageOnFileSelect = () => {
  const formWithImages = document.querySelector('.form-with-images');
  if (formWithImages) {
    formWithImages.querySelectorAll('.image-input input').forEach(imageInput => {
      imageInput.addEventListener('change', () => {
        const imagePreview = formWithImages.querySelector(`.image-preview[data-id='${imageInput.dataset.id}']`);
        if (imageInput.files && imageInput.files[0]) {
          const reader = new FileReader();
          reader.onload = event => {
            imagePreview.src = event.currentTarget.result;
          };
          reader.readAsDataURL(imageInput.files[0]);
          imagePreview.classList.remove('display-none');
        }
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/price_range_slider.js":
/*!*********************************************************!*\
  !*** ./app/javascript/components/price_range_slider.js ***!
  \*********************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   priceRangeSlider: function() { return /* binding */ priceRangeSlider; }
/* harmony export */ });
const priceRangeSlider = () => {
  const priceRangeSliders = document.querySelectorAll('.price-range-slider');
  if (priceRangeSliders.length > 0) {
    priceRangeSliders.forEach(priceRangeSlider => {
      const ranges = priceRangeSlider.querySelectorAll('input[type="range"]');
      const currentValues = priceRangeSlider.querySelectorAll('.current-values span');
      ranges.forEach(range => {
        range.oninput = () => {
          let slide1 = parseFloat(ranges[0].value);
          let slide2 = parseFloat(ranges[1].value);
          if (slide1 > slide2) {
            [slide1, slide2] = [slide2, slide1];
          }
          currentValues[0].innerHTML = `$${slide1}`;
          currentValues[1].innerHTML = `$${slide2}`;
        };
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/product_show_thumbnails.js":
/*!**************************************************************!*\
  !*** ./app/javascript/components/product_show_thumbnails.js ***!
  \**************************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   productShowThumbnails: function() { return /* binding */ productShowThumbnails; }
/* harmony export */ });
// Update the main image and the selected thumbnail when a thumbnail is clicked
const productShowThumbnails = () => {
  const thumbnailsContainer = document.querySelectorAll('#product-show #thumbnails');
  if (thumbnailsContainer) {
    const mainImage = document.querySelector('#product-show #main-image img');
    const thumbnails = document.querySelectorAll('#thumbnails .thumbnail');
    const replaceMainImageSrc = ({
      imageUrl,
      key
    }) => {
      mainImage.src = imageUrl;
      mainImage.dataset.key = key;
    };
    const setSelectedThumbnail = () => {
      thumbnails.forEach(thumbnail => {
        if (thumbnail.dataset.key === mainImage.dataset.key) {
          thumbnail.classList.add('selected');
        } else {
          thumbnail.classList.remove('selected');
        }
      });
    };
    thumbnails.forEach(thumbnail => {
      thumbnail.addEventListener('click', event => {
        replaceMainImageSrc(event.currentTarget.dataset);
        setSelectedThumbnail();
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/product_show_variants.js":
/*!************************************************************!*\
  !*** ./app/javascript/components/product_show_variants.js ***!
  \************************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   productShowVariants: function() { return /* binding */ productShowVariants; }
/* harmony export */ });
// Update variant information on product show (price, add to cart btn, image, thumbnail, available options etc...) regarding what variant is selected
const productShowVariants = () => {
  const productShow = document.querySelector('#product-show');
  const productVariants = productShow?.querySelector('#product-variants');
  if (productVariants) {
    const cartForm = productShow.querySelector('#cart-form > form');
    const mainImage = productShow.querySelector('#main-image img');
    const variantIdInput = cartForm.querySelector('#variant_id');

    // Update the quantity selector with the total stock
    // and enable/disable the add and remove quantity trigger regarding the stock level of the new variant
    const updateQuantityInput = ({
      totalStock
    }) => {
      const quantityInput = cartForm.querySelector('.add-to-cart .quantity-selector input#quantity');
      const addQuantityTrigger = cartForm.querySelector('.add-to-cart .quantity-selector span[data-type="add"]');
      const removeQuantityTrigger = cartForm.querySelector('.add-to-cart .quantity-selector span[data-type="remove"]');
      quantityInput.value = 1;
      quantityInput.dataset.totalStock = totalStock;
      removeQuantityTrigger.classList.add('disabled');
      if (totalStock > 1) {
        addQuantityTrigger.classList.remove('disabled');
      } else {
        addQuantityTrigger.classList.add('disabled');
      }
    };

    // Enable/disable add to cart btn and update its text regarding if variant is available or not
    const updateAddToCartBtn = ({
      totalStock
    }) => {
      const addToCartBtn = cartForm.querySelector('.add-to-cart #add-to-cart-btn');
      const itemPropAvailability = cartForm.querySelector('link[itemprop=availability]');
      if (totalStock > 0) {
        addToCartBtn.disabled = false;
        addToCartBtn.innerHTML = addToCartBtn.dataset.buy.toUpperCase();
        itemPropAvailability.href = 'http://schema.org/InStock';
      } else {
        addToCartBtn.disabled = true;
        addToCartBtn.innerHTML = addToCartBtn.dataset.outOfStock.toUpperCase();
        itemPropAvailability.href = 'http://schema.org/OutOfStock';
      }
    };

    // Update price (and discount price) regarding what variant is selected
    const updateVariantPrice = ({
      price,
      discountPrice,
      onSale
    }) => {
      const priceTag = cartForm.querySelector('#product-price .price.original');
      priceTag.innerHTML = price;
      const discountPriceTag = cartForm.querySelector('#product-price .price.discount');
      discountPriceTag.innerHTML = discountPrice;
      const itemPropPrice = cartForm.querySelector('meta[itemprop=price]');
      if (onSale) {
        priceTag.classList.add('crossed');
        discountPriceTag.classList.remove('display-none');
        itemPropPrice.content = discountPrice.replace('$', '');
      } else {
        discountPriceTag.classList.add('display-none');
        priceTag.classList.remove('crossed');
        itemPropPrice.content = price.replace('$', '');
      }
    };

    // Update image regarding what variant is selected
    const updateVariantImage = ({
      imageUrl,
      imageKey,
      imageAlt
    }) => {
      mainImage.src = imageUrl;
      mainImage.dataset.key = imageKey;
      mainImage.alt = imageAlt;
    };

    // Update thumbnails regarding what variant is selected
    const updateThumbnails = ({
      id
    }) => {
      const thumbnails = productShow.querySelectorAll('#thumbnails .thumbnail');
      thumbnails.forEach(thumbnail => {
        if (parseInt(thumbnail.dataset.variantId) === id) {
          thumbnail.style.display = 'block';
          if (thumbnail.dataset.key == mainImage.dataset.key) {
            thumbnail.classList.add('selected');
          } else {
            thumbnail.classList.remove('selected');
          }
        } else {
          thumbnail.style.display = 'none';
        }
      });
    };

    // Update url params with the new variant id
    // And the schema itemprop url meta tag with the new url
    const updateCurrentUrl = variantId => {
      const url = new URL(window.location);
      url.searchParams.set('variant_id', variantId);
      history.replaceState(history.state, '', url);
      productShow.querySelector('[itemprop=url]').content = url;
    };

    // Update the schema itemprop condition meta tag with the new variant condition
    const updateConditionMetaTag = variantCondition => {
      const conditionMetaTag = productShow.querySelector('[itemprop=itemCondition]');
      conditionMetaTag.href = variantCondition === 'original' ? 'http://schema.org/NewCondition' : 'http://schema.org/RefurbishedCondition';
    };

    // Fetch the selected variant thanks to the current selected option values
    // Then call the different methods to update all the variant informations (price, image, thumbnails etc...)
    const updateVariantInformations = () => {
      const formData = new FormData(cartForm);
      const queryString = new URLSearchParams(formData);
      fetch(`/products/variant_with_options_hash?${queryString}`, {
        headers: {
          'accept': 'application/json'
        }
      }).then(response => response.json()).then(variant => {
        variantIdInput.value = variant.id;
        updateVariantImage(variant);
        updateThumbnails(variant);
        updateQuantityInput(variant);
        updateAddToCartBtn(variant);
        updateVariantPrice(variant);
        updateCurrentUrl(variant.id);
        updateConditionMetaTag(variant.condition);
      });
    };

    // Update variant information when page loads
    updateVariantInformations();
    const productId = cartForm.querySelector('#product_id').value;
    Array.from(cartForm.elements).forEach(formElement => {
      // Add an event listener to all inputs of the "cart form" used to select variant options
      formElement.addEventListener('change', event => {
        // When an option value is selected call /products/product_variants_with_option_values
        // This endpoints will find all variants of this product that have this option value
        // And then returns a hash of those variants option values grouped by option type
        const selectedOptionValue = event.currentTarget;

        // Changing quantity is also part of the cartForm but we handle it in a separate quantity_selector.js file,
        // because it is not related to variant changes, and not specific to product show.
        if (selectedOptionValue.name == 'quantity') {
          return;
        }
        ;
        const selectedOptionTypeId = selectedOptionValue.tagName === 'SELECT' ? selectedOptionValue.dataset.id : selectedOptionValue.dataset.optionTypeId;
        const queryString = `product_id=${productId}&selected_option_type=${selectedOptionTypeId}&selected_option_value=${selectedOptionValue.value}`;
        fetch(`/products/product_variants_with_option_values?${queryString}`, {
          headers: {
            'accept': 'application/json'
          }
        }).then(response => response.json()).then(optionValuesByOptionType => {
          // For each option types returned, find the corresponding option values on the page and then:
          // - If this option type is the one that the user just selected, we enable all option values (Because we want the user to be able to change the option value of the selected option type)
          // - If not, disable/enable option values that are not included in the returned results from the endpoint (Indeed it means that for the selected option type, there are no variant with those option values, so we need to prevent user from selecting it)
          // - After doing this process, if one (previously) selected option value is now disabled, we need to change it. So we find the first not-disabled option value of the same option type and select it.
          Object.entries(optionValuesByOptionType).forEach(optionType => {
            const optionValueTags = Array.from(cartForm.querySelectorAll(`[data-option-type-id='${optionType[0]}']`));

            // The "model" option type is returned by the endpoint but is hidden on the page by default,
            // so we won't find a corresponding option value tags. In that case we just skip it and pass to the next iteration
            if (optionValueTags.length == 0) {
              return;
            }
            ;
            if (selectedOptionTypeId === optionType[0]) {
              optionValueTags.forEach(optionValueTag => optionValueTag.disabled = false);
            } else {
              optionValueTags.forEach(optionValueTag => {
                optionValueTag.disabled = !optionType[1].some(optionValue => optionValue.id === parseInt(optionValueTag.value));
              });
              if (optionValueTags.find(optionValueTag => optionValueTag.selected || optionValueTag.checked)?.disabled) {
                const firstNonDisabledOptionValue = optionValueTags.find(optionValueTag => optionValueTag.disabled === false);
                switch (firstNonDisabledOptionValue.tagName) {
                  case 'INPUT':
                    firstNonDisabledOptionValue.checked = true;
                    break;
                  case 'OPTION':
                    firstNonDisabledOptionValue.selected = true;
                    break;
                }
              }
            }
          });
          // When we all this process is done we can ends up with a new set of selected option values.
          // We thus need to fetch the corresponding variant and update all variant informations.
          updateVariantInformations();
        });
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/products_filters_form.js":
/*!************************************************************!*\
  !*** ./app/javascript/components/products_filters_form.js ***!
  \************************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   productsFiltersForm: function() { return /* binding */ productsFiltersForm; }
/* harmony export */ });
// Update product grid with the relevant products when a products filter (or sorting) is selected
const productsFiltersForm = () => {
  const productsSearcherForm = document.querySelector('form#products-filters-form');
  if (productsSearcherForm) {
    // HTML of a product card
    const productCardHtml = product => {
      return `
        <li id=\"product_${product.id}\" data-hook="products_list_item" itemscope itemtype="http://schema.org/Product">
          <div class="product-image">
            <img src="${product.image_url}">
          </div>
          <div class="product-name">${product.name}</div>
          <span class="prices" itemprop="offers" itemscope itemtype="http://schema.org/Offer">
            ${product.cheapest_variant_onsale ? discountPriceHtml(product.discount_price, product.discount_price_html_tag) : ''}
            <span class="price selling ${product.cheapest_variant_onsale ? 'crossed' : ''} itemprop="price" content="${product.price}">
              ${product.price_html_tag}
            </span>
          </span>
          <a href=${product.url} class="product-link full-absolute" itemprop="name" title=${product.name}></a>
        </li >
      `;
    };

    // HTML of a discount price to display if a product is on sale
    const discountPriceHtml = (discountPrice, discountPriceHtmlTag) => {
      return `
        <span class="price selling" itemprop="price" content="${discountPrice}">
          ${discountPriceHtmlTag}
        </span >
      `;
    };

    // To display if no products are found
    const displayNoProductsMessage = noProductMessage => {
      document.getElementById('products').innerHTML = `
        <div>
          ${noProductMessage}
        </div>
      `;
    };

    // Display all newly found products
    const updateProducts = products => {
      const productsGrid = document.getElementById('products');
      productsGrid.innerHTML = '';
      products.forEach(product => {
        productsGrid.insertAdjacentHTML('beforeend', productCardHtml(product));
      });
    };

    // On mobile we display the number of selected filters (on the filters modal trigger, and erase filter button)
    // This method update filters count each time a filter is added/removed
    const updateFilterCount = formDataEntries => {
      const priceRangeSlider = productsSearcherForm.querySelector('.price-range-slider .slider input');
      if (!priceRangeSlider) {
        return;
      }
      let count = 0;
      const priceRangeSlideMinMax = [priceRangeSlider.min, priceRangeSlider.max];

      // Loop over all filters to determine if we count it or not.
      // Indeed, we don't count "sorting", and we count price range only if they have been used (if the values are different from the original min and max values)
      for (const [key, value] of formDataEntries) {
        if (key === 'search[price_between][]') {
          if (!priceRangeSlideMinMax.includes(value)) {
            count += 1;
          }
        } else if (key.startsWith('search')) {
          count += 1;
        }
      }
      const filterCounts = document.querySelectorAll('#products-sidebar .filter-count');
      filterCounts.forEach(filterCount => {
        filterCount.innerHTML = count > 0 ? `(${count})` : '';
      });
    };

    // Fetch products each time a filter change. (We don't wait for form submission)
    [...productsSearcherForm.elements].forEach(input => {
      input.addEventListener('change', () => {
        const formData = new FormData(productsSearcherForm);
        const queryString = new URLSearchParams(formData);

        // The searchKeywords is not part of the products filters form (its part of the products search form),
        // but needs to be added here in case users refine search results with filters
        const searchKeywordsQuery = new URLSearchParams(window.location.search).get('keywords');
        if (searchKeywordsQuery) {
          queryString.set('keywords', searchKeywordsQuery);
        }

        // Fetch new products from those form data
        fetch(`/products/filter?${queryString.toString()}`, {
          headers: {
            'accept': 'application/json'
          }
        }).then(response => response.json()).then(({
          products,
          noProductsMessage
        }) => {
          products.length === 0 ? displayNoProductsMessage(noProductsMessage) : updateProducts(products);
        });
        updateFilterCount(formData.entries());
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/products_search.js":
/*!******************************************************!*\
  !*** ./app/javascript/components/products_search.js ***!
  \******************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   productsSearch: function() { return /* binding */ productsSearch; }
/* harmony export */ });
// Focus on search input when products search model is open
const productsSearch = () => {
  const productsSearchModal = document.querySelector('#productsSearchModal');
  if (productsSearchModal) {
    productsSearchModal.addEventListener('shown.bs.modal', () => {
      productsSearchModal.querySelector('input#keywords').focus();
    });
  }
  ;
};


/***/ }),

/***/ "./app/javascript/components/products_sidebar.js":
/*!*******************************************************!*\
  !*** ./app/javascript/components/products_sidebar.js ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   productsSidebar: function() { return /* binding */ productsSidebar; }
/* harmony export */ });
// On desktop the products filters are on a sidebar and the products sorting is a dropdown,
// on mobile both are in a modal in 2 different tabs
// So we need to adapt those different elements to mobile/desktop views
const productsSidebar = () => {
  const productsSidebar = document.getElementById('products-sidebar');
  if (productsSidebar) {
    const body = document.querySelector('body');
    const productsSidebarContent = productsSidebar.querySelector('#products-sidebar-content');
    const showProductsSidebarContentBtn = productsSidebar.querySelector('#show-products-sidebar-content');
    const hideProductsSidebarContentBtns = productsSidebar.querySelectorAll('.hide-products-sidebar-content');

    // Add bootstrap tab classes to show the products filters tab by default
    // (and hide the products sorting tab)
    const displayFilterTab = () => {
      const filterTabId = 'product-filters-tab';
      const sortingTabId = 'products-sorting-tab';
      const productsFilterTabBtn = productsSidebar.querySelector(`#${filterTabId}`);
      const productsSortingTabBtn = productsSidebar.querySelector(`#${sortingTabId}`);
      const productsFilterTabContent = productsSidebar.querySelector(`#${filterTabId}-content`);
      const productsSortingTabContent = productsSidebar.querySelector(`#${sortingTabId}-content`);
      productsFilterTabBtn.classList.add('active');
      productsFilterTabBtn.ariaSelected = true;
      productsSortingTabBtn.classList.remove('active');
      productsSortingTabBtn.ariaSelected = false;
      productsFilterTabContent.classList.add('active', 'show');
      productsSortingTabContent.classList.remove('active', 'show');
    };

    // On desktop, show the products sidebar,
    // on mobile show the products filters and sorting modal
    const setProductsSidebar = () => {
      if (window.innerWidth > 767) {
        productsSidebarContent.classList.remove('mobile');
        productsSidebarContent.classList.remove('show');
      } else {
        productsSidebarContent.classList.add('mobile');
        body.classList.remove('overflow-hidden');
        displayFilterTab();
      }
    };
    window.addEventListener('resize', () => {
      setProductsSidebar();
    });
    setProductsSidebar();

    // Button that opens the products filters and sorting modal
    showProductsSidebarContentBtn.addEventListener('click', () => {
      body.classList.add('overflow-hidden', 'position-relative');
      const contentOverlay = document.createElement('div');
      contentOverlay.classList.add('content-overlay');
      body.appendChild(contentOverlay);
      productsSidebarContent.classList.add('show');
    });

    // Buttons that hide the products filters and sorting modal
    hideProductsSidebarContentBtns.forEach(hideProductsSidebarContentBtn => {
      hideProductsSidebarContentBtn.addEventListener('click', () => {
        productsSidebarContent.classList.remove('show');
        document.querySelector('.content-overlay').remove();
        body.classList.remove('overflow-hidden', 'position-relative');
      });
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/products_sorting.js":
/*!*******************************************************!*\
  !*** ./app/javascript/components/products_sorting.js ***!
  \*******************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   productsSorting: function() { return /* binding */ productsSorting; }
/* harmony export */ });
// Set products sorting displayed text regarding what sorting is currently applied
const productsSorting = () => {
  // There are actually 2 products sortings. So this selector will get the first one,
  // it is enough to know if we should execute this script or not
  // (But we won't use it later in the script because we need to work with both forms)
  const productsSorting = document.querySelector('.products-sorting');
  if (productsSorting) {
    const currentProductsSorting = document.getElementById('current-products-sorting');
    const productsSortingOptions = document.querySelectorAll('.products-sorting-option input');
    productsSortingOptions.forEach(productsSortingOption => {
      productsSortingOption.addEventListener('change', event => {
        const selectedSortingKey = event.currentTarget.value;
        productsSortingOptions.forEach(option => option.classList.remove('selected'));
        document.querySelectorAll(`input[value=${selectedSortingKey}]`).forEach(selectedSortingInput => {
          selectedSortingInput.checked = true;
          // we need this .selected class because the default :checked css selector does not work properly,
          // because those inputs are displayed 2 times on the same page, so we have 2 inputs with the same id...
          selectedSortingInput.classList.add('selected');
        });
        currentProductsSorting.innerHTML = event.currentTarget.dataset.label;
      });
    });
  }
  ;
};


/***/ }),

/***/ "./app/javascript/components/quantity_selector.js":
/*!********************************************************!*\
  !*** ./app/javascript/components/quantity_selector.js ***!
  \********************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   quantitySelector: function() { return /* binding */ quantitySelector; }
/* harmony export */ });
const quantitySelector = () => {
  const quantitySelector = document.querySelector('.quantity-selector');
  if (quantitySelector) {
    const quantityInput = quantitySelector.querySelector('input');
    const addQuantityTrigger = quantitySelector.querySelector('span[data-type="add"');
    const removeQuantityTrigger = quantitySelector.querySelector('span[data-type="remove"');
    const changeQuantity = newQuantity => {
      const totalStock = parseInt(quantityInput.dataset.totalStock);
      if (totalStock === 1 || totalStock === 0) {
        quantityInput.value = 1;
      } else if (newQuantity <= 1) {
        quantityInput.value = 1;
        removeQuantityTrigger.classList.add('disabled');
        addQuantityTrigger.classList.remove('disabled');
      } else {
        if (newQuantity >= totalStock) {
          quantityInput.value = totalStock;
          addQuantityTrigger.classList.add('disabled');
          removeQuantityTrigger.classList.remove('disabled');
        } else {
          quantityInput.value = newQuantity;
          addQuantityTrigger.classList.remove('disabled');
        }
        removeQuantityTrigger.classList.remove('disabled');
      }
    };
    addQuantityTrigger.addEventListener('click', _event => {
      changeQuantity(parseInt(quantityInput.value) + 1);
    });
    removeQuantityTrigger.addEventListener('click', _event => {
      changeQuantity(parseInt(quantityInput.value) - 1);
    });
    quantityInput.addEventListener('change', _event => {
      let selectedQuantity = parseInt(quantityInput.value);
      selectedQuantity = isNaN(selectedQuantity) ? 1 : selectedQuantity;
      changeQuantity(selectedQuantity);
    });
  }
};


/***/ }),

/***/ "./app/javascript/components/trade_in_form.js":
/*!****************************************************!*\
  !*** ./app/javascript/components/trade_in_form.js ***!
  \****************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   tradeInForm: function() { return /* binding */ tradeInForm; }
/* harmony export */ });
const tradeInForm = () => {
  const tradeInForm = document.querySelector('#trade-in-form form');
  if (tradeInForm) {
    const tradeInCategories = tradeInForm.querySelector('#trade-in-categories');
    const tradeInModels = tradeInForm.querySelector('#trade-in-models');
    const tradeInModelPrice = tradeInForm.querySelector('.trade-in-model-price');
    const tradeInSecondPart = tradeInForm.querySelector('.trade-in-second-part');
    const taxons = tradeInForm.querySelector('#taxons');
    const products = tradeInForm.querySelector('#products');
    const variants = tradeInForm.querySelector('#variants');
    const variantInfos = tradeInForm.querySelector('.variant-infos');
    const invalidTradeIn = tradeInForm.querySelector('#invalid-trade-in');
    const tradeInCta = tradeInForm.querySelector('#trade-in-cta');
    const show = (...elements) => {
      elements.forEach(element => {
        element.disabled = false;
        element.classList.remove('hidden');
      });
    };
    const hide = (...elements) => {
      elements.forEach(element => {
        element.disabled = true;
        element.classList.add('hidden');
      });
    };

    // Update variant infos (price, image, name, max value, min value),
    // (Method called when a new variant is selected, when a new product without variant is selected, or when a new trade in model is selected)
    const changeVariantInfos = variantId => {
      hide(variantInfos, tradeInCta);
      const params = `trade_in_min_value=${tradeInModelPrice.dataset.minValue}&trade_in_max_value=${tradeInModelPrice.dataset.maxValue}`;
      fetch(`/trade_in_requests/variant_infos/${variantId}/?${params}`, {
        headers: {
          'accept': 'application/json'
        }
      }).then(response => response.json()).then(({
        tradeInIsValid,
        imageTag,
        name,
        options,
        minValue,
        maxValue,
        price
      }) => {
        variantInfos.dataset.id = variantId;
        if (tradeInIsValid) {
          variantInfos.querySelector('.variant-image').innerHTML = imageTag;
          variantInfos.querySelector('.variant-name').innerHTML = name;
          variantInfos.querySelector('.variant-options').innerHTML = options;
          variantInfos.querySelector('.variant-min-price').innerHTML = minValue;
          variantInfos.querySelector('.variant-max-price').innerHTML = maxValue;
          variantInfos.querySelector('.variant-price').innerHTML = price;
          invalidTradeIn.classList.add('display-none');
          show(variantInfos, tradeInCta);
        } else {
          invalidTradeIn.classList.remove('display-none');
        }
      });
    };

    // Update trade in model infos (name, min value, max value),
    // (Method called when a new trade in model is selected)
    const changeTradeInModelPrice = selectedModel => {
      tradeInModelPrice.querySelector('.model-name').innerHTML = selectedModel.innerHTML;
      tradeInModelPrice.querySelector('.model-min-value').innerHTML = selectedModel.dataset.minValueText;
      tradeInModelPrice.querySelector('.model-max-value').innerHTML = selectedModel.dataset.maxValueText;
      show(tradeInModelPrice);
      tradeInModelPrice.dataset.minValue = selectedModel.dataset.minValue;
      tradeInModelPrice.dataset.maxValue = selectedModel.dataset.maxValue;
      tradeInModelPrice.querySelector('input#trade-in-model-min-value').value = selectedModel.dataset.minValue;
      tradeInModelPrice.querySelector('input#trade-in-model-max-value').value = selectedModel.dataset.maxValue;
      tradeInModelPrice.querySelector('input#trade-in-model-name').value = selectedModel.innerHTML;
      show(tradeInSecondPart, taxons);
    };

    // Show/hide the correct select options of children depending on what parent is selected
    // (Method called when a new parent is selected)
    // We can't just display/hide the relevant options with CSS because safari browsers don't apply CSS on option tags...
    const displayOptionsOfSelectedParent = (childrenSelectTag, parentId) => {
      // Reset children select tag
      childrenSelectTag.value = '';
      childrenSelectTag.innerHTML = '';

      // Add children select tag prompt
      const prompt = document.createElement('option');
      prompt.text = childrenSelectTag.dataset.prompt;
      childrenSelectTag.add(prompt, 0);

      // Retrieve all children select tag options (from an hidden div on the DOM)
      const selectId = childrenSelectTag.id;
      const optionsForSelect = [...tradeInForm.querySelectorAll(`.options-for-select[data-select-id=${selectId}] option`)];

      // Add the relevant options to children select tag depending on what parent is selected
      optionsForSelect.forEach(option => {
        if (option.dataset.parentId === parentId) {
          childrenSelectTag.add(option.cloneNode(true));
        }
      });

      // Display children select tag
      show(childrenSelectTag);
    };

    // When selected trade in category change:
    // - Hide trade in model price (in case it was already displayed)
    // - Hide variant infos (in case it was already displayed)
    // - Show the trade in models corresponding to the new selected trade in category (and hide the others)
    tradeInCategories.addEventListener('change', event => {
      hide(tradeInModelPrice, variantInfos, tradeInCta);
      displayOptionsOfSelectedParent(tradeInModels, event.currentTarget.value);
    });

    // When selected trade in model change:
    // - If the first option (the text placeholder), hide trade in model price and variant info (in case it was already displayed)
    // - Update trade in model price with the infos of the new selected trade in model (name, min value, max value...)
    // - Show the trade in model price
    // - Update trade in model price data infos (minValue, maxValue)
    // - Show the second part of the trade in form
    // - If a variant is already selected, update its infos
    tradeInModels.addEventListener('change', event => {
      if (tradeInModels.selectedIndex === 0) {
        hide(tradeInModelPrice, variantInfos, tradeInCta);
      } else {
        changeTradeInModelPrice(event.currentTarget.selectedOptions[0]);
        if (variantInfos.dataset.id) {
          changeVariantInfos(variantInfos.dataset.id);
        }
      }
    });

    // When selected taxon change:
    // - Hide all variant options, variant infos and delete variant infos id (so that if trade in model change it won't trigger changes on variant infos)
    // - Show the products corresponding to the new selected taxon (and hide the others)
    taxons.addEventListener('change', event => {
      [...variants.options].forEach((option, index) => {
        if (index > 0) {
          option.remove();
        }
      });
      delete variantInfos.dataset.id;
      hide(variantInfos, tradeInCta);
      displayOptionsOfSelectedParent(products, event.currentTarget.value);
    });

    // When selected product change:
    // - If this product has variants or if the option is the placeholder
    //    - Show variants
    //    - Hide variant infos (in case it was already displayed) and delete the variant info id
    //    - Show the variants options corresponding to the new selected product (and hide the others)
    // - Else if trade in model price is not set
    //    - Hide variants
    //    - Set the variant info id with the product master id (will be used to display the correct variant infos when a trade in model is selected)
    // - Else this product don't have variants:
    //    - hide variants
    //    - change variant infos with the porduct master id
    products.addEventListener('change', event => {
      const productSelect = event.currentTarget;
      const selectedOption = productSelect.selectedOptions[0];
      if (selectedOption.dataset.hasVariants === 'true' || productSelect.selectedIndex === 0) {
        show(variants);
        hide(variantInfos, tradeInCta);
        delete variantInfos.dataset.id;
        displayOptionsOfSelectedParent(variants, productSelect.value);
      } else if (tradeInModelPrice.classList.contains('hidden')) {
        hide(variants);
        variantInfos.dataset.id = selectedOption.dataset.masterId;
      } else {
        hide(variants);
        changeVariantInfos(selectedOption.dataset.masterId);
      }
    });

    // When selected variant change:
    // - If the options is the placeholder, hide variant infos and delete the variant info id
    // - Else if trade in model price is not set, set the variant info id with the variant id
    // - Else change variant infos
    variants.addEventListener('change', event => {
      const variantSelect = event.currentTarget;
      if (variantSelect.selectedIndex === 0) {
        delete variantInfos.dataset.id;
        hide(variantInfos, tradeInCta);
      } else if (tradeInModelPrice.classList.contains('hidden')) {
        variantInfos.dataset.id = variantSelect.value;
      } else {
        changeVariantInfos(variantSelect.value);
      }
    });

    // If showFields is set to true, display all hidden fields by default
    // This happens when user tries to submit a form with errors,
    // the page is re-rendered and we need to display everything
    if (tradeInForm.dataset.showFields === 'true') {
      displayOptionsOfSelectedParent(tradeInModels, tradeInCategories.value);
      displayOptionsOfSelectedParent(products, taxons.value);
      changeTradeInModelPrice(tradeInModels.selectedOptions[0]);
      const selectedProduct = products.selectedOptions[0];
      if (selectedProduct.dataset.hasVariants === 'true') {
        displayOptionsOfSelectedParent(variants, products.value);
        changeVariantInfos(variants.value);
        show(variants);
      } else {
        changeVariantInfos(selectedProduct.dataset.masterId);
      }
      show(tradeInCategories, tradeInModels, tradeInModelPrice, tradeInSecondPart, taxons, products, variantInfos, invalidTradeIn, tradeInCta);
      window.Modal = __webpack_require__(/*! bootstrap/js/dist/modal */ "./node_modules/bootstrap/js/dist/modal.js");
      const myModal = new Modal(document.getElementById('tradeInFormModal'));
      myModal.show();
    }
  }
};


/***/ }),

/***/ "./app/javascript/plugins/init_mapbox.js":
/*!***********************************************!*\
  !*** ./app/javascript/plugins/init_mapbox.js ***!
  \***********************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   initMapbox: function() { return /* binding */ initMapbox; }
/* harmony export */ });
/* harmony import */ var _mapbox_gl__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! !mapbox-gl */ "./node_modules/mapbox-gl/dist/mapbox-gl.js");
/* harmony import */ var _mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_mapbox_gl__WEBPACK_IMPORTED_MODULE_0__);
// Importing mapbox-gl with a bang (!mapbox-gl) exclude mapbox-gl from being transpiled by webpack

const initMapbox = () => {
  const mapElement = document.getElementById('map');

  // Shown on the address page when defining shipping address
  if (mapElement) {
    // Get latitude and longitude hidden inputs
    const latitudeInput = document.querySelector('[data-input="address_latitude"]');
    const longitudeInput = document.querySelector('[data-input="address_longitude"]');

    // Method that update the value of latitude and longitude hidden inputs
    const updateCoordinates = () => {
      latitudeInput.value = marker.getLngLat().lat;
      longitudeInput.value = marker.getLngLat().lng;
    };

    // Update de displayed map by doing 3 things:
    // - puting the marker on the center of the selected area
    // - resizing the map
    // - puting the center of the map on the selected area
    const updateMap = (latitude, longitude) => {
      marker.setLngLat([longitude, latitude]);
      map.resize();
      map.flyTo({
        center: [longitude, latitude]
      });
    };

    // initialize a mapbox map in the center of Panama
    (_mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default().accessToken) = gon.mapbox_api_key;
    const map = new (_mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default().Map)({
      container: 'map',
      // container ID
      style: 'mapbox://styles/mapbox/streets-v11',
      // style URL
      center: [-79.528142, 8.975448],
      // starting position [lng, lat]
      zoom: 15 // starting zoom
    });

    // Create a new draggable market on the map, and put it by default in the center of Panama
    const marker = new (_mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default().Marker)({
      draggable: true
    }).setLngLat([-79.528142, 8.975448]).addTo(map);

    // Every time the marker is dragged, call updateCoordinates method
    marker.on('dragend', updateCoordinates);

    // When loading the page, call updateMap() if a point on the map has already been defined
    // (It happens if user select a point on the map, validates, and then comes back to the page)
    if (latitudeInput.value && longitudeInput.value) {
      updateMap(latitudeInput.value, longitudeInput.value);
    }

    // Add en event listener on the area (corregimiento) input
    // and update the map each time it changes
    // + Nullify latitude and longitude hidden fields value, to be sure user will move the marker
    const corregimientoInput = document.querySelector('[data-input="district_id"]');
    corregimientoInput.addEventListener('change', event => {
      const indexOfSelectedDistrict = corregimientoInput.options.selectedIndex;
      const latitude = parseFloat(corregimientoInput.options[indexOfSelectedDistrict].dataset.latitude);
      const longitude = parseFloat(corregimientoInput.options[indexOfSelectedDistrict].dataset.longitude);
      updateMap(latitude, longitude);
      latitudeInput.value = longitudeInput.value = null;
    });

    // Prevent form submission if map marker have not been set
    const submitAddressBtn = document.querySelector('input[type=submit][data-input="map_submit"]');
    submitAddressBtn.addEventListener('click', event => {
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
    const {
      latitude,
      longitude
    } = staticMapElement.dataset;
    // initialize a mapbox map with shipping address coordinate
    (_mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default().accessToken) = gon.mapbox_api_key;
    const map = new (_mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default().Map)({
      container: 'static-map',
      // container ID
      style: 'mapbox://styles/mapbox/streets-v11',
      // style URL
      center: [longitude, latitude],
      // starting position [lng, lat]
      zoom: 15 // starting zoom
    });

    new (_mapbox_gl__WEBPACK_IMPORTED_MODULE_0___default().Marker)().setLngLat([longitude, latitude]).addTo(map);
  }
};


/***/ }),

/***/ "./app/javascript/plugins/swiper_slider.js":
/*!*************************************************!*\
  !*** ./app/javascript/plugins/swiper_slider.js ***!
  \*************************************************/
/***/ (function(__unused_webpack_module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export */ __webpack_require__.d(__webpack_exports__, {
/* harmony export */   swiperSlider: function() { return /* binding */ swiperSlider; }
/* harmony export */ });
/* harmony import */ var swiper__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! swiper */ "./node_modules/swiper/swiper.esm.js");
// import Swiper JS: https://swiperjs.com/

swiper__WEBPACK_IMPORTED_MODULE_0__["default"].use([swiper__WEBPACK_IMPORTED_MODULE_0__.Autoplay, swiper__WEBPACK_IMPORTED_MODULE_0__.Navigation, swiper__WEBPACK_IMPORTED_MODULE_0__.Pagination, swiper__WEBPACK_IMPORTED_MODULE_0__.Manipulation]); // https://github.com/JayChase/angular2-useful-swiper/issues/48

const swiperSlider = () => {
  const sliders = document.querySelectorAll('.swiper');
  if (sliders.length > 0) {
    // Add slides to slider
    const addRelevantSlides = (slider, slides) => {
      // Because swiper needs at least 1 slide to initiate loop we can't just remove all slides at the same time
      // So we 1) add a placeholder > 2) remove all other slides > 3) add new slides > 4) remove placeholder
      slider.prependSlide('<div class="swiper-slide placeholder-slide">'); // 1)
      slider.removeSlide([...Array(slider.slides.length).keys()].slice(1)); // 2)
      slider.appendSlide(slides.map(({
        link,
        images,
        alt
      }) => {
        // 3)
        return `<div class="swiper-slide centered-flexbox">
          ${link ? `<a href="${decodeURIComponent(link)}">` : ''}
            <img src="${images[slider.currentBreakpoint]}", alt="${decodeURIComponent(alt).replace(/\+/g, ' ')}" />
          ${link ? `</a>` : ''}
        </div>`;
      }));
      slider.removeSlide(0); // 4)
    };

    // Generate sliders with correct options for all DOM elements that have the .swiper class
    sliders.forEach(slider => {
      // Get slider options from HTML view
      const sliderOptions = JSON.parse(slider.dataset.sliderOptions);

      // Initialize swiper instance with the slider options
      const swiperSlider = new swiper__WEBPACK_IMPORTED_MODULE_0__["default"](`.swiper[data-slider-id="${slider.dataset.sliderId}"]`, {
        loop: true,
        spaceBetween: sliderOptions.spaceBetweenSlides,
        navigation: sliderOptions.navigation ? {
          nextEl: '.swiper-next',
          prevEl: '.swiper-prev'
        } : false,
        pagination: sliderOptions.pagination ? {
          el: '.swiper-pagination',
          clickable: true
        } : false,
        autoplay: {
          enabled: sliderOptions.autoplay,
          delay: sliderOptions.delayBetweenSlides,
          disableOnInteraction: false
        },
        breakpoints: {
          576: {
            slidesPerView: sliderOptions.imagePerSlideS
          },
          768: {
            slidesPerView: sliderOptions.imagePerSlideM
          },
          992: {
            slidesPerView: sliderOptions.imagePerSlideL
          },
          1200: {
            slidesPerView: sliderOptions.imagePerSlideXl
          },
          1400: {
            // We don't use this breakpoint for imagePerSlide config, but use it to display the slide image at the correct size
            slidesPerView: sliderOptions.imagePerSlideXl
          }
        }
      });
      if (sliderOptions.disableLoop) {
        swiperSlider.disable();
      }

      // Get slide data from HTML view
      const slides = JSON.parse(slider.dataset.slides);
      addRelevantSlides(swiperSlider, slides);
      // Whenever windows size hit a new breakpoint, update sliders with slides of the correct size
      swiperSlider.on('breakpoint', () => addRelevantSlides(swiperSlider, slides));
    });
  }
};


/***/ })

},
/******/ function(__webpack_require__) { // webpackRuntimeModules
/******/ var __webpack_exec__ = function(moduleId) { return __webpack_require__(__webpack_require__.s = moduleId); }
/******/ __webpack_require__.O(0, ["vendors-node_modules_rails_activestorage_app_assets_javascripts_activestorage_js-node_modules-530a8b"], function() { return __webpack_exec__("./app/javascript/application.js"); });
/******/ var __webpack_exports__ = __webpack_require__.O();
/******/ }
]);
//# sourceMappingURL=application.js.map