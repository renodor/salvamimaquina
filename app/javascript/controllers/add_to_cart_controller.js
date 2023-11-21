import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('ici')
    const cartForm = document.querySelector('#cart-form form');

    // Listen on cart form ajax:success event (when a variant has successfully been added to cart), and:
    // - update the navbar cart counter
    // - display the add to cart modal with the variant name
    cartForm.addEventListener('ajax:success', (event) => {
      debugger
      console.log('youhouuu')
      const payload = event.detail[0];

      const cartQuantityTag = document.querySelector('#navbar-icons .navbar-cart-quantity');

      if (cartQuantityTag) {
        const newCartQuantity = parseInt(cartQuantityTag.innerHTML) + payload.quantity;
        cartQuantityTag.innerHTML = newCartQuantity;
        cartQuantityTag.classList.remove('display-none');
      }

      const addToCartModal = document.getElementById('addToCartModal');
      addToCartModal.querySelector('.modal-body #variant-name').innerHTML = payload.variantName;
      window.Modal = require('bootstrap/js/dist/modal');
      new Modal(addToCartModal).show();
    });

    // Listen on cart form ajax:error event (when there is an error trying to add a product to cart), and:
    // - display a flash error message
    cartForm.addEventListener('ajax:error', (event) => (addFlashToDom(event.detail[0].flash)));
  }
}
