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
        const selectedOptionType = event.currentTarget.name.match(/option_type_(\d+)/)[1];
        const selectedOptionValue = event.currentTarget.value;
        const queryString = `product_id=${productId}&selected_option_type=${selectedOptionType}&selected_option_value=${selectedOptionValue}`;

        fetch(`/products/product_variants_with_option_values?${queryString}`, { headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then((optionValuesByOptionType) => {
              Object.entries(optionValuesByOptionType).forEach((optionType) => {
                const formSelect = cartForm.elements[`variant_options[option_type_${optionType[0]}]`];
                const formSelectOptions = formSelect.options;
                const formSelectOptionsArray = Array.from(formSelectOptions);

                if (selectedOptionType === optionType[0]) {
                  formSelectOptionsArray.forEach((formSelectOption) => formSelectOption.disabled = false);
                } else {
                  formSelectOptionsArray.forEach((formSelectOption) => {
                    formSelectOption.disabled = !optionType[1].some((optionValue) => optionValue.id === parseInt(formSelectOption.value));
                  });

                  if (formSelectOptions[formSelect.selectedIndex].disabled == true) {
                    const IndexOfFirstEnabledOption = formSelectOptionsArray.findIndex((option) => option.disabled === false);
                    formSelectOptions.selectedIndex = IndexOfFirstEnabledOption;
                  }
                }
              });
            })
            .then(() => {
              const formData = new FormData(cartForm);
              const newQueryString = new URLSearchParams(formData);
              fetch(`/products/variant_with_options_hash?${newQueryString}`, { headers: { 'accept': 'application/json' } })
                  .then((response) => response.json())
                  .then((variant) => {
                    updateAddToCartBtn(variant);
                    updateVariantPrice(variant);
                  });
            });
      });
    });
  }
};

export { cartForm };
