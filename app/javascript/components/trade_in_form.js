const tradeInForm = document.querySelector('#trade-in-form form');

console.log('ici')
if (tradeInForm) {
  console.log('et la')
  const tradeInCategories = tradeInForm.querySelector('#trade-in-categories');
  const tradeInModels = tradeInForm.querySelector('#trade-in-models');
  const tradeInModelPrice = tradeInForm.querySelector('.trade-in-model-price');
  const tradeInSecondPart = tradeInForm.querySelector('.trade-in-second-part');
  const taxons = tradeInForm.querySelector('#taxons');
  const products = tradeInForm.querySelector('#products');
  const variants = tradeInForm.querySelector('#variants');
  const variantInfos = tradeInForm.querySelector('.variant-infos');
  const invalidTradeIn = tradeInForm.querySelector('#invalid-trade-in');
  const tradeInCta = tradeInForm.querySelector('#trade-in-cta');

  const show = (...elements) => {
    elements.forEach((element) => {
      element.disabled = false;
      element.classList.remove('hidden');
    });
  };

  const hide = (...elements) => {
    elements.forEach((element) => {
      element.disabled = true;
      element.classList.add('hidden');
    });
  };

  // Update variant infos (price, image, name, max value, min value),
  // (Method called when a new variant is selected, when a new product without variant is selected, or when a new trade in model is selected)
  const changeVariantInfos = (variantId) => {
    hide(variantInfos, tradeInCta);
    const params = `trade_in_min_value=${tradeInModelPrice.dataset.minValue}&trade_in_max_value=${tradeInModelPrice.dataset.maxValue}`;
    fetch(`/trade_in_requests/variant_infos/${variantId}/?${params}`, { headers: { 'accept': 'application/json' } })
        .then((response) => response.json())
        .then(({ tradeInIsValid, imageTag, name, options, minValue, maxValue, price }) => {
          variantInfos.dataset.id = variantId;
          if (tradeInIsValid) {
            variantInfos.querySelector('.variant-image').innerHTML = imageTag;
            variantInfos.querySelector('.variant-name').innerHTML = name;
            variantInfos.querySelector('.variant-options').innerHTML = options;
            variantInfos.querySelector('.variant-min-price').innerHTML = minValue;
            variantInfos.querySelector('.variant-max-price').innerHTML = maxValue;
            variantInfos.querySelector('.variant-price').innerHTML = price;
            invalidTradeIn.classList.add('display-none');
            show(variantInfos, tradeInCta);
          } else {
            invalidTradeIn.classList.remove('display-none');
          }
        });
  };

  // Update trade in model infos (name, min value, max value),
  // (Method called when a new trade in model is selected)
  const changeTradeInModelPrice = (selectedModel) => {
    tradeInModelPrice.querySelector('.model-name').innerHTML = selectedModel.innerHTML;
    tradeInModelPrice.querySelector('.model-min-value').innerHTML = selectedModel.dataset.minValueText;
    tradeInModelPrice.querySelector('.model-max-value').innerHTML = selectedModel.dataset.maxValueText;
    show(tradeInModelPrice);

    tradeInModelPrice.dataset.minValue = selectedModel.dataset.minValue;
    tradeInModelPrice.dataset.maxValue = selectedModel.dataset.maxValue;
    tradeInModelPrice.querySelector('input#trade-in-model-min-value').value = selectedModel.dataset.minValue;
    tradeInModelPrice.querySelector('input#trade-in-model-max-value').value = selectedModel.dataset.maxValue;
    tradeInModelPrice.querySelector('input#trade-in-model-name').value = selectedModel.innerHTML;

    show(tradeInSecondPart, taxons);
  };

  // Show/hide the correct select options of children depending on what parent is selected
  // (Method called when a new parent is selected)
  // We can't just display/hide the relevant options with CSS because safari browsers don't apply CSS on option tags...
  const displayOptionsOfSelectedParent = (childrenSelectTag, parentId) => {
    // Reset children select tag
    childrenSelectTag.value = '';
    childrenSelectTag.innerHTML = '';

    // Add children select tag prompt
    const prompt = document.createElement('option');
    prompt.text = childrenSelectTag.dataset.prompt;
    childrenSelectTag.add(prompt, 0);

    // Retrieve all children select tag options (from an hidden div on the DOM)
    const selectId = childrenSelectTag.id;
    const optionsForSelect = [...tradeInForm.querySelectorAll(`.options-for-select[data-select-id=${selectId}] option`)];

    // Add the relevant options to children select tag depending on what parent is selected
    optionsForSelect.forEach((option) => {
      if (option.dataset.parentId === parentId) {
        childrenSelectTag.add(option.cloneNode(true));
      }
    });

    // Display children select tag
    show(childrenSelectTag);
  };

  // When selected trade in category change:
  // - Hide trade in model price (in case it was already displayed)
  // - Hide variant infos (in case it was already displayed)
  // - Show the trade in models corresponding to the new selected trade in category (and hide the others)
  tradeInCategories.addEventListener('change', (event) => {
    hide(tradeInModelPrice, variantInfos, tradeInCta);
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
      hide(tradeInModelPrice, variantInfos, tradeInCta);
    } else {
      changeTradeInModelPrice(event.currentTarget.selectedOptions[0]);

      if (variantInfos.dataset.id) {
        changeVariantInfos(variantInfos.dataset.id);
      }
    }
  });

  // When selected taxon change:
  // - Hide all variant options, variant infos and delete variant infos id (so that if trade in model change it won't trigger changes on variant infos)
  // - Show the products corresponding to the new selected taxon (and hide the others)
  taxons.addEventListener('change', (event) => {
    [...variants.options].forEach((option, index) => {
      if (index > 0) {
        option.remove();
      }
    });

    delete variantInfos.dataset.id;
    hide(variantInfos, tradeInCta);

    displayOptionsOfSelectedParent(products, event.currentTarget.value);
  });

  // When selected product change:
  // - If this product has variants or if the option is the placeholder
  //    - Show variants
  //    - Hide variant infos (in case it was already displayed) and delete the variant info id
  //    - Show the variants options corresponding to the new selected product (and hide the others)
  // - Else if trade in model price is not set
  //    - Hide variants
  //    - Set the variant info id with the product master id (will be used to display the correct variant infos when a trade in model is selected)
  // - Else this product don't have variants:
  //    - hide variants
  //    - change variant infos with the porduct master id
  products.addEventListener('change', (event) => {
    const productSelect = event.currentTarget;
    const selectedOption = productSelect.selectedOptions[0];
    if (selectedOption.dataset.hasVariants === 'true' || productSelect.selectedIndex === 0) {
      show(variants);
      hide(variantInfos, tradeInCta);
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

  // When selected variant change:
  // - If the options is the placeholder, hide variant infos and delete the variant info id
  // - Else if trade in model price is not set, set the variant info id with the variant id
  // - Else change variant infos
  variants.addEventListener('change', (event) => {
    const variantSelect = event.currentTarget;
    if (variantSelect.selectedIndex === 0) {
      delete variantInfos.dataset.id;
      hide(variantInfos, tradeInCta);
    } else if (tradeInModelPrice.classList.contains('hidden')) {
      variantInfos.dataset.id = variantSelect.value;
    } else {
      changeVariantInfos(variantSelect.value);
    }
  });

  // If showFields is set to true, display all hidden fields by default
  // This happens when user tries to submit a form with errors,
  // the page is re-rendered and we need to display everything
  if (tradeInForm.dataset.showFields === 'true') {
    displayOptionsOfSelectedParent(tradeInModels, tradeInCategories.value);
    displayOptionsOfSelectedParent(products, taxons.value);
    changeTradeInModelPrice(tradeInModels.selectedOptions[0]);

    const selectedProduct = products.selectedOptions[0];
    if (selectedProduct.dataset.hasVariants === 'true') {
      displayOptionsOfSelectedParent(variants, products.value);
      changeVariantInfos(variants.value);
      show(variants);
    } else {
      changeVariantInfos(selectedProduct.dataset.masterId);
    }

    show(
        tradeInCategories,
        tradeInModels,
        tradeInModelPrice,
        tradeInSecondPart,
        taxons,
        products,
        variantInfos,
        invalidTradeIn,
        tradeInCta
    );

    window.Modal = require('bootstrap/js/dist/modal');
    const myModal = new Modal(document.getElementById('tradeInFormModal'));
    myModal.show();
  }
}