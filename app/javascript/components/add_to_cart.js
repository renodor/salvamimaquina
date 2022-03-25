// Update front end when a variant has been added to cart (via Ajax)
const addToCart = () => {
  const cartForm = document.querySelector('#cart-form form');

  if (cartForm) {
    window.Modal = require('bootstrap/js/dist/modal');

    // Listen on cart form ajax:success event (when a variant has successfully been added to cart), and:
    // - update the navbar cart counter
    // - display the add to cart modal with the variant name
    cartForm.addEventListener('ajax:success', (event) => {
      const payload = event.detail[0];

      const cartQuantityTag = document.querySelector('#navbar-icons .navbar-cart-quantity');
      const newCartQuantity = parseInt(cartQuantityTag.innerHTML) + payload.quantity;
      cartQuantityTag.innerHTML = newCartQuantity;
      cartQuantityTag.classList.remove('display-none');

      const addToCartModal = document.getElementById('addToCartModal');
      addToCartModal.querySelector('.modal-body #variant-name').innerHTML = payload.variantName;
      new Modal(addToCartModal).show();
    });

    // Listen on cart form ajax:error event (when there is an error trying to add a product to cart), and:
    // - display a flash error message
    cartForm.addEventListener('ajax:error', (event) => {
      const content = document.querySelector('body #wrapper #content');
      content.insertAdjacentHTML('afterbegin', `
        <div class="flash error">${event.detail[0].error}</div>
      `);
    });
  }
};

export { addToCart };
