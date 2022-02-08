const tradeInForm = () => {
  const tradeInForm = document.getElementById('trade-in-form');

  if (tradeInForm) {
    const tradeInCategories = tradeInForm.querySelector('#trade-in-categories');
    const tradeInModels = tradeInForm.querySelector('#trade-in-models');
    const tradeInModelPrice = tradeInForm.querySelector('#trade-in-model-price');
    const taxons = tradeInForm.querySelector('#taxons');
    const products = tradeInForm.querySelector('#products');
    const variants = tradeInForm.querySelector('#variants');
    const variantInfos = tradeInForm.querySelector('#variant-infos');

    const show = (element) => {
      element.disabled = false;
      element.classList.remove('hidden');
    };

    const hide = (element) => {
      element.disabled = true;
      element.classList.add('hidden');
    };
    // Update variant infos (price, image, name, max value, min value),
    // (Method called when a new variant is selected, or when a new trade in model is selected)
    const changeVariantInfos = (variantId) => {
      hide(variantInfos);
      const params = `trade_in_min_value=${tradeInModelPrice.dataset.minValue}&trade_in_max_value=${tradeInModelPrice.dataset.maxValue}`;
      fetch(`/trade_in/${variantId}/variant_infos/?${params}`, { headers: { 'accept': 'application/json' } })
          .then((response) => response.json())
          .then(({ imageTag, name, options, minValue, maxValue, price }) => {
            variantInfos.querySelector('.variant-image').innerHTML = imageTag;
            variantInfos.querySelector('.variant-name').innerHTML = name;
            variantInfos.querySelector('.variant-options').innerHTML = options;
            variantInfos.querySelector('.variant-min-price').innerHTML = minValue;
            variantInfos.querySelector('.variant-max-price').innerHTML = maxValue;
            variantInfos.querySelector('.variant-price').innerHTML = price;
            variantInfos.dataset.id = variantId;
            show(variantInfos);
          });
    };

    // Show/hide the correct select options of children
    // (Method called when a new parent is selected)
    const displayOptionsOfSelectedParent = (childrenSelectTag, parentId) => {
      childrenSelectTag.value = '';
      Array.from(childrenSelectTag.options).forEach((option, index) => {
        if (index === 0) { return; }

        if (option.dataset.parentId === parentId) {
          option.classList.remove('display-none');
        } else {
          option.classList.add('display-none');
        }
      });
      show(childrenSelectTag);
    };

    // When selected trade in category change:
    // - Hide trade in model price (in case it was already displayed)
    // - Hide variant infos (in case it was already displayed)
    // - Show the trade in models corresponding to the new selected trade in category (and hide the others)
    tradeInCategories.addEventListener('change', (event) => {
      hide(tradeInModelPrice);
      hide(variantInfos);
      displayOptionsOfSelectedParent(tradeInModels, event.currentTarget.value);
    });

    // When selected trade in model change:
    // - If the first option (the text placeholder), hide trade in model price and variant info (in case it was already displayed)
    // - Update trade in model price with the infos of the new selected trade in model (name, min value, max value...)
    // - Show the trade in model price
    // - Update trade in model price data infos (minValue, maxValue)
    // - Show the second part of the trade in form
    // - If a variant is already selected, update its infos
    tradeInModels.addEventListener('change', (event) => {
      if (tradeInModels.selectedIndex === 0) {
        hide(tradeInModelPrice);
        hide(variantInfos);
      } else {
        const selectedModel = event.currentTarget.selectedOptions[0];
        tradeInModelPrice.querySelector('.model-name').innerHTML = selectedModel.innerHTML;
        tradeInModelPrice.querySelector('.model-min-value').innerHTML = selectedModel.dataset.minValueText;
        tradeInModelPrice.querySelector('.model-max-value').innerHTML = selectedModel.dataset.maxValueText;
        show(tradeInModelPrice);

        tradeInModelPrice.dataset.minValue = selectedModel.dataset.minValue;
        tradeInModelPrice.dataset.maxValue = selectedModel.dataset.maxValue;

        show(tradeInForm.querySelector('#trade-in-second-part'));

        if (variantInfos.dataset.id) {
          changeVariantInfos(variantInfos.dataset.id);
        }
      }
    });

    // When selected taxon change:
    // - Hide all variant options and variant infos
    // - Show the products corresponding to the new selected taxon (and hide the others)
    taxons.addEventListener('change', (event) => {
      variants.value = '';
      Array.from(variants.options).forEach((option, index) => {
        if (index === 0) { return; }

        option.classList.add('display-none');
      });

      hide(variantInfos);
      delete variantInfos.dataset.id;

      displayOptionsOfSelectedParent(products, event.currentTarget.value);
    });

    // When selected product change:
    // - If this product has variants:
    //    - show variants
    //    - Hide variant infos (in case it was already displayed)
    //    - Show the variants options corresponding to the new selected product (and hide the others)
    // - if this product don't have variants:
    //    - hide variants
    //    - change variant infos
    products.addEventListener('change', (event) => {
      const productSelect = event.currentTarget;
      const selectedOption = productSelect.selectedOptions[0];
      if (selectedOption.dataset.hasVariants === 'true' || productSelect.selectedIndex === 0) {
        show(variants);
        hide(variantInfos);
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

    // When selected variant change, change variant infos
    variants.addEventListener('change', (event) => {
      const variantSelect = event.currentTarget;
      if (variantSelect.selectedIndex === 0) {
        hide(variantInfos);
        delete variantInfos.dataset.id;
      } else if (tradeInModelPrice.classList.contains('hidden')) {
        variantInfos.dataset.id = variantSelect.value;
      } else {
        changeVariantInfos(variantSelect.value);
      }
    });
  }
};

export { tradeInForm };
