const productShow = () => {
  const cartForm = document.getElementById('cart-form');

  if (cartForm) {
    const productVariants = cartForm.querySelectorAll('#inside-product-cart-form #product-variants input');

    // On product show, if product has variants, enable/disable add to cart button regarding if the selected variant has stock or not
    if (productVariants.length > 0) {
      const addToCartButton = cartForm.querySelector('.add-to-cart button[type=submit]');
      const enableAddToCartButton = () => {
        addToCartButton.disabled = false;
        addToCartButton.innerHTML = 'COMPRAR'; // TODO: fetch this text from backend
      };

      const disableAddToCartButton = () => {
        addToCartButton.disabled = true;
        addToCartButton.innerHTML = 'AGOTADO'; // TODO: fetch this text from backend
      };

      const setAddToCartBtnState = (variant) => {
        variant.dataset.hasStock === 'true' ? enableAddToCartButton() : disableAddToCartButton();
      };

      productVariants.forEach((variant) => {
        if (variant.checked) {
          setAddToCartBtnState(variant);
        }

        variant.oninput = () => {
          setAddToCartBtnState(variant);
        };
      });
    }
  }
};

export { productShow };
