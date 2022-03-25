const addToCart = () => {
  const cartForm = document.querySelector('#cart-form form');

  if (cartForm) {
    window.Modal = require('bootstrap/js/dist/modal');

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

    cartForm.addEventListener('ajax:error', (event) => {
      const content = document.querySelector('body #wrapper #content');
      content.insertAdjacentHTML('afterbegin', `
        <div class="flash error">${event.detail[0].error}</div>
      `)
    });
  }
};

export { addToCart };
