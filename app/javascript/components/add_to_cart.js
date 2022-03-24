const addToCart = () => {
  const cartForm = document.querySelector('#cart-form form');

  if (cartForm) {
    window.Modal = require('bootstrap/js/dist/modal');

    cartForm.addEventListener('ajax:success', (event) => {
      // currently can't disable Eslint for that because of this bug: https://github.com/typescript-eslint/typescript-eslint/issues/4691

      /* eslint-disable */
      const [payload, _status, _xhr] = event.detail; 
      /* eslint-enable */

      const cartQuantityTag = document.querySelector('#navbar-icons .navbar-cart-quantity');
      const newCartQuantity = parseInt(cartQuantityTag.innerHTML) + payload.quantity;
      cartQuantityTag.innerHTML = newCartQuantity;
      cartQuantityTag.classList.remove('display-none');

      const addToCartModal = document.getElementById('addToCartModal');
      addToCartModal.querySelector('.modal-body #variant-name').innerHTML = payload.variantName;
      new Modal(addToCartModal).show();
    });

    cartForm.addEventListener('ajax:error', (event) => {
      console.log(event.detail);
    });
  }
};

export { addToCart };
