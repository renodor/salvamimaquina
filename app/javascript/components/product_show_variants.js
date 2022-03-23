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
    const updateQuantityInput = ({ totalStock }) => {
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
    const updateAddToCartBtn = ({ totalStock }) => {
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
    const updateVariantPrice = ({ price, discountPrice, onSale }) => {
      const priceTag = cartForm.querySelector('#product-price .price.original');
      priceTag.innerHTML = price;
      const discountPriceTag = cartForm.querySelector('#product-price .price.discount');
      discountPriceTag.innerHTML = discountPrice;

      const itemPropPrice = cartForm.querySelector('meta[itemprop=price]');

      if (onSale) {
        priceTag.classList.add('crossed');
        discountPriceTag.classList.remove('display-none');
        itemPropPrice.content = price.replace('$', '');
      } else {
        discountPriceTag.classList.add('display-none');
        priceTag.classList.remove('crossed');
        itemPropPrice.content = discountPrice.replace('$', '');
      }
    };

    // Update image regarding what variant is selected
    const updateVariantImage = ({ imageUrl, imageKey }) => {
      mainImage.src = imageUrl;
      mainImage.dataset.key = imageKey;
    };

    // Update thumbnails regarding what variant is selected
    const updateThumbnails = ({ id }) => {
      const thumbnails = productShow.querySelectorAll('#thumbnails .thumbnail');
      thumbnails.forEach((thumbnail) => {
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
    // And the itemprop url meta tag with the new url
    const updateCurrentUrl = (variantId) => {
      const url = new URL(window.location);
      url.searchParams.set('variant_id', variantId);
      history.replaceState(history.state, '', url);
      productShow.querySelector('[itemprop=url]').content = url;
    };

    // Fetch the selected variant thanks to the current selected option values
    // Then call the different methods to update all the variant informations (price, image, thumbnails etc...)
    const updateVariantInformations = () => {
      const formData = new FormData(cartForm);
      const queryString = new URLSearchParams(formData);
      fetch(`/products/variant_with_options_hash?${queryString}`, { headers: { 'accept': 'application/json' } })
          .then((response) => response.json())
          .then((variant) => {
            variantIdInput.value = variant.id;
            updateVariantImage(variant);
            updateThumbnails(variant);
            updateQuantityInput(variant);
            updateAddToCartBtn(variant);
            updateVariantPrice(variant);
            updateCurrentUrl(variant.id);
          });
    };

    // Update variant information when page loads
    updateVariantInformations();

    const productId = cartForm.querySelector('#product_id').value;
    Array.from(cartForm.elements).forEach((formElement) => {
      // Add an event listener to all inputs of the "cart form" used to select variant options
      formElement.addEventListener('change', (event) => {
        // When an option value is selected call /products/product_variants_with_option_values
        // This endpoints will find all variants of this product that have this option value
        // And then returns a hash of those variants option values grouped by option type
        const selectedOptionValue = event.currentTarget;

        // Changing quantity is also part of the cartForm but we handle it in a separate quantity_selector.js file,
        // because it is not related to variant changes, and not specific to product show.
        if (selectedOptionValue.name == 'quantity') { return; };

        const selectedOptionTypeId = selectedOptionValue.tagName === 'SELECT' ? selectedOptionValue.dataset.id : selectedOptionValue.dataset.optionTypeId;
        const queryString = `product_id=${productId}&selected_option_type=${selectedOptionTypeId}&selected_option_value=${selectedOptionValue.value}`;
        fetch(`/products/product_variants_with_option_values?${queryString}`, { headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then((optionValuesByOptionType) => {
              // For each option types returned, find the corresponding option values on the page and then:
              // - If this option type is the one that the user just selected, we enable all option values (Because we want the user to be able to change the option value of the selected option type)
              // - If not, disable/enable option values that are not included in the returned results from the endpoint (Indeed it means that for the selected option type, there are no variant with those option values, so we need to prevent user from selecting it)
              // - After doing this process, if one (previously) selected option value is now disabled, we need to change it. So we find the first not-disabled option value of the same option type and select it.
              Object.entries(optionValuesByOptionType).forEach((optionType) => {
                const optionValueTags = Array.from(cartForm.querySelectorAll(`[data-option-type-id='${optionType[0]}']`));

                // The "model" option type is returned by the endpoint but is hidden on the page by default,
                // so we won't find a corresponding option value tags. In that case we just skip it and pass to the next iteration
                if (optionValueTags.length == 0) { return; };

                if (selectedOptionTypeId === optionType[0]) {
                  optionValueTags.forEach((optionValueTag) => optionValueTag.disabled = false);
                } else {
                  optionValueTags.forEach((optionValueTag) => {
                    optionValueTag.disabled = !optionType[1].some((optionValue) => optionValue.id === parseInt(optionValueTag.value));
                  });

                  if (optionValueTags.find((optionValueTag) => optionValueTag.selected || optionValueTag.checked)?.disabled) {
                    const firstNonDisabledOptionValue = optionValueTags.find((optionValueTag) => optionValueTag.disabled === false);
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

export { productShowVariants };
