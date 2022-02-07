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

    // Update variant infos (price, image, name, max value, min value),
    // (Method called when a new variant is selected, or when a new trade in model is selected)
    const changeVariantInfos = (variantId) => {
      variantInfos.classList.add('hidden');
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
          });
      variantInfos.dataset.isDisplayed = true;
      variantInfos.dataset.id = variantId;
      variantInfos.classList.remove('hidden');
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
      childrenSelectTag.classList.remove('hidden');
    };

    // When selected trade in category change:
    // - Hide trade in model price (in case it was already displayed)
    // - Hide variant infos (in case it was already displayed)
    // - Show the trade in models corresponding to the new selected trade in category (and hide the others)
    tradeInCategories.addEventListener('change', (event) => {
      tradeInModelPrice.classList.add('hidden');
      variantInfos.classList.add('hidden');
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
        tradeInModelPrice.classList.add('hidden');
        variantInfos.classList.add('hidden');
      } else {
        const selectedModel = event.currentTarget.selectedOptions[0];
        tradeInModelPrice.querySelector('.model-name').innerHTML = selectedModel.innerHTML;
        tradeInModelPrice.querySelector('.model-min-value').innerHTML = selectedModel.dataset.minValueText;
        tradeInModelPrice.querySelector('.model-max-value').innerHTML = selectedModel.dataset.maxValueText;
        tradeInModelPrice.classList.remove('hidden');

        tradeInModelPrice.dataset.minValue = selectedModel.dataset.minValue;
        tradeInModelPrice.dataset.maxValue = selectedModel.dataset.maxValue;

        tradeInForm.querySelector('#trade-in-second-part').classList.remove('hidden');

        if (variantInfos.dataset.isDisplayed) {
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

      variantInfos.classList.add('hidden');

      displayOptionsOfSelectedParent(products, event.currentTarget.value);
    });

    // When selected product change:
    // - If this product has variants:
    //    - Hide variant infos (in case it was already displayed)
    //    - Show the variants corresponding to the new selected paroduct (and hide the others)
    // - if this product don't have variants:
    //    - change variant infos
    products.addEventListener('change', (event) => {
      if (event.currentTarget.selectedOptions[0].dataset.hasVariants === 'true') {
        variantInfos.classList.add('hidden');
        displayOptionsOfSelectedParent(variants, event.currentTarget.value);
      } else {
        changeVariantInfos(event.currentTarget.selectedOptions[0].dataset.masterId);
      }
    });

    // When selected variant change, change variant infos
    variants.addEventListener('change', (event) => (changeVariantInfos(event.currentTarget.value)));
  }
};

export { tradeInForm };
