const tradeInForm = () => {
  const tradeInForm = document.getElementById('trade-in-form');

  if (tradeInForm) {
    // const displayCorrectChildrenOnParentSelect = (parentElement, childrenContainerClass, childrenClass) => {
    //   parentElement.addEventListener('change', (event) => {
    //     const childrenContainer = tradeInForm.querySelector(childrenContainerClass);
    //     childrenContainer.classList.remove('hidden');

    //     childrenContainer.querySelectorAll(childrenClass).forEach((childElement) => {
    //       childElement.value = '';
    //       if (childElement.dataset.parentId === event.currentTarget.value) {
    //         childElement.classList.remove('display-none');
    //         childElement.dataset.selected = true;
    //       } else {
    //         childElement.classList.add('display-none');
    //         childElement.dataset.selected = false;
    //       }
    //     });
    //   });
    // };

    const selectTradeInCategories = tradeInForm.querySelector('#trade-in-categories select');
    selectTradeInCategories.addEventListener('change', (event) => {
      const tradeInModelPrice = tradeInForm.querySelector('#trade-in-model-price');
      tradeInModelPrice.classList.add('hidden');

      const tradeInModels = tradeInForm.querySelector('#trade-in-models');
      tradeInModels.value = '';
      Array.from(tradeInModels.options).forEach((option, index) => {
        if (index === 0) { return; }

        if (option.dataset.tradeInCategoryId === event.currentTarget.value) {
          option.classList.remove('display-none');
        } else {
          option.classList.add('display-none');
        }
      });
      tradeInModels.classList.remove('hidden');
    });

    const tradeInModels = tradeInForm.querySelector('#trade-in-models');
    tradeInModels.addEventListener('change', (event) => {
      const tradeInModelPrice = tradeInForm.querySelector('#trade-in-model-price');

      if (tradeInModels.selectedIndex === 0) {
        tradeInModelPrice.classList.add('hidden');
      } else {
        const selectedModel = event.currentTarget.selectedOptions[0];
        tradeInModelPrice.querySelector('.model-name').innerHTML = selectedModel.innerHTML;
        tradeInModelPrice.querySelector('.model-min-value').innerHTML = selectedModel.dataset.minValue;
        tradeInModelPrice.querySelector('.model-max-value').innerHTML = selectedModel.dataset.maxValue;
        tradeInModelPrice.classList.remove('hidden');

        tradeInForm.querySelector('#trade-in-second-part').classList.remove('hidden');
      }
    });

    const selectTaxon = tradeInForm.querySelector('#taxons select');
    selectTaxon.addEventListener('change', (event) => {
      // const tradeInModelPrice = tradeInForm.querySelector('#trade-in-model-price');
      // tradeInModelPrice.classList.add('hidden');

      const products = tradeInForm.querySelector('#products');
      products.value = '';
      Array.from(products.options).forEach((option, index) => {
        if (index === 0) { return; }

        if (option.dataset.taxonId === event.currentTarget.value) {
          option.classList.remove('display-none');
        } else {
          option.classList.add('display-none');
        }
      });
      products.classList.remove('hidden');
    });

    const selectProduct = tradeInForm.querySelector('#products');
    selectProduct.addEventListener('change', (event) => {
      // const tradeInModelPrice = tradeInForm.querySelector('#trade-in-model-price');
      // tradeInModelPrice.classList.add('hidden');

      const variants = tradeInForm.querySelector('#variants');
      variants.value = '';
      Array.from(variants.options).forEach((option, index) => {
        if (index === 0) { return; }

        if (option.dataset.productId === event.currentTarget.value) {
          option.classList.remove('display-none');
        } else {
          option.classList.add('display-none');
        }
      });
      variants.classList.remove('hidden');
    });

    const selectVariants = tradeInForm.querySelectorAll('#variants select');
    selectVariants.forEach((selectVariant) => {
      selectVariant.addEventListener('change', (event) => {
        const selectedVariantId = event.currentTarget.value;
        tradeInForm.querySelectorAll('#variant-infos .variant-info').forEach((variantInfo) => {
          if (variantInfo.dataset.parentId == selectedVariantId) {
            variantInfo.classList.remove('display-none');
            window.setTimeout(() => {
              variantInfo.classList.remove('hidden');
            }, 0);

            const selectedTradeInModelPrice = tradeInForm.querySelector('#trade-in-model-prices .trade-in-model-price[data-selected=true]');
            const minValue = parseFloat(selectedTradeInModelPrice.dataset.minValue);
            const maxValue = parseFloat(selectedTradeInModelPrice.dataset.maxValue);

            const variantPrice = parseFloat(variantInfo.dataset.price);
            const priceToCompute = variantInfo.querySelector('.price-to-compute');

            priceToCompute.querySelector('.min-price').innerHTML = variantPrice - minValue;
            priceToCompute.querySelector('.max-price').innerHTML = variantPrice - maxValue;
          } else {
            variantInfo.classList.add('display-none', 'hidden');
          }
        });
      });
    });
  }
};

export { tradeInForm };
