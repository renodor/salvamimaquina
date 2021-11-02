const cartForm = () => {
  const cartForm = document.querySelector('#cart-form > form');

  if (cartForm) {
    const updateAddToCartBtn = ({ hasStock }) => {
      const addToCartBtn = cartForm.querySelector('.add-to-cart button');
      if (hasStock) {
        addToCartBtn.disabled = false;
        addToCartBtn.innerHTML = addToCartBtn.dataset.buy.toUpperCase();
      } else {
        addToCartBtn.disabled = true;
        addToCartBtn.innerHTML = addToCartBtn.dataset.outOfStock.toUpperCase();
      }
    };

    const updateVariantPrice = ({ price, discountPrice, onSale }) => {
      const priceTag = cartForm.querySelector('#product-price .price.original');
      priceTag.innerHTML = price;
      const discountPriceTag = cartForm.querySelector('#product-price .price.discount');
      discountPriceTag.innerHTML = discountPrice;

      if (onSale) {
        priceTag.classList.add('crossed');
        discountPriceTag.classList.remove('display-none');
      } else {
        discountPriceTag.classList.add('display-none');
        priceTag.classList.remove('crossed');
      }
    };

    const productId = cartForm.querySelector('#product_id').value;
    Array.from(cartForm.elements).forEach((formElement) => {
      formElement.addEventListener('change', (event) => {
        const selectedOptionValue = event.currentTarget;
        const selectedOptionTypeId = selectedOptionValue.tagName === 'SELECT' ? selectedOptionValue.dataset.id : selectedOptionValue.dataset.optionTypeId;
        const queryString = `product_id=${productId}&selected_option_type=${selectedOptionTypeId}&selected_option_value=${selectedOptionValue.value}`;
        fetch(`/products/product_variants_with_option_values?${queryString}`, { headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then((optionValuesByOptionType) => {
              Object.entries(optionValuesByOptionType).forEach((optionType) => {
                const optionValueTags = Array.from(cartForm.querySelectorAll(`[data-option-type-id='${optionType[0]}']`));

                if (selectedOptionTypeId === optionType[0]) {
                  optionValueTags.forEach((optionValueTag) => optionValueTag.disabled = false);
                } else {
                  optionValueTags.forEach((optionValueTag) => {
                    optionValueTag.disabled = !optionType[1].some((optionValue) => optionValue.id === parseInt(optionValueTag.value));
                  });

                  if (optionValueTags.find((optionValueTag) => optionValueTag.selected)?.disabled == true) {
                    optionValueTags.find((optionValueTag) => optionValueTag.disabled === false).selected = true;
                  }
                }
              });
            });
      // .then(() => {
      //   const formData = new FormData(cartForm);
      //   const newQueryString = new URLSearchParams(formData);
      //   fetch(`/products/variant_with_options_hash?${newQueryString}`, { headers: { 'accept': 'application/json' } })
      //       .then((response) => response.json())
      //       .then((variant) => {
      //         updateAddToCartBtn(variant);
      //         updateVariantPrice(variant);
      //       });
      // });
      });
    });
  }
};

export { cartForm };
