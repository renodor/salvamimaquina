const tradeInForm = () => {
  const tradeInForm = document.getElementById('trade-in-form');

  if (tradeInForm) {
    const relvealElementWithTransition = (element) => {
      element.classList.remove('display-none');
      window.setTimeout(() => {
        element.classList.remove('hidden');
      }, 0);
      element.dataset.hidden = false;
    };

    const relvealElement = (element) => {
      element.classList.remove('display-none');
      element.classList.remove('hidden');
      element.dataset.hidden = false;
    };

    const hideElement = (element) => {
      element.classList.add('display-none');
      element.classList.add('hidden');
      element.dataset.hidden = true;
    };

    const selectCategories = tradeInForm.querySelector('#trade_in_categories');
    const displaySelectedTradeInModelPrices = (selectedTradeInModelId) => {
      const selectModels = tradeInForm.querySelectorAll('#trade-in-models select');
      selectModels.forEach((tradeInModel) => {
        if (tradeInModel.dataset.parentId == selectedTradeInModelId) {
          if (Array.from(selectModels).every((model) => model.dataset.hidden == 'false')) {
            relvealElement(tradeInModel);
          } else {
            relvealElementWithTransition(tradeInModel);
          }
        } else {
          hideElement(tradeInModel);
        }
      });
    };

    selectCategories.addEventListener('change', (event) => {
      displaySelectedTradeInModelPrices(event.currentTarget.value);
    });

    displaySelectedTradeInModelPrices(selectCategories.value);

    const selectModels = tradeInForm.querySelectorAll('#trade-in-models select');
    selectModels.forEach((selectModel) => {
      selectModel.addEventListener('change', (event) => {
        const selectedModelId = event.currentTarget.value;
        tradeInForm.querySelector('#trade-in-second-part').classList.remove('hidden');
        tradeInForm.querySelectorAll('#trade-in-model-prices .trade-in-model-price').forEach((tradeInModelPrice) => {
          if (tradeInModelPrice.dataset.parentId == selectedModelId) {
            tradeInModelPrice.classList.remove('hidden');
            tradeInModelPrice.dataset.selected = true;
          } else {
            tradeInModelPrice.classList.add('hidden');
            tradeInModelPrice.dataset.selected = false;
          }
        });
      });
    });

    const selectTaxon = tradeInForm.querySelector('#taxons select');
    selectTaxon.addEventListener('change', (event) => {
      const selectedTaxonId = event.currentTarget.value;
      tradeInForm.querySelectorAll('#products .product').forEach((product) => {
        if (product.dataset.parentId == selectedTaxonId) {
          product.classList.remove('hidden');
        } else {
          product.classList.add('hidden');
        }
      });
    });

    const selectProducts = tradeInForm.querySelectorAll('#products select');
    selectProducts.forEach((selectProduct) => {
      selectProduct.addEventListener('change', (event) => {
        const selectedProductId = event.currentTarget.value;
        tradeInForm.querySelectorAll('#variants .variant').forEach((variant) => {
          if (variant.dataset.parentId == selectedProductId) {
            variant.classList.remove('hidden');
          } else {
            variant.classList.add('hidden');
          }
        });
      });
    });

    const selectVariants = tradeInForm.querySelectorAll('#variants select');
    selectVariants.forEach((selectVariant) => {
      selectVariant.addEventListener('change', (event) => {
        const selectedVariantId = event.currentTarget.value;
        tradeInForm.querySelectorAll('#variant-infos .variant-info').forEach((variantInfo) => {
          if (variantInfo.dataset.parentId == selectedVariantId) {
            variantInfo.classList.remove('hidden');

            const selectedTradeInModelPrice = tradeInForm.querySelector('#trade-in-model-prices .trade-in-model-price[data-selected=true]');
            const minValue = parseFloat(selectedTradeInModelPrice.dataset.minValue);
            const maxValue = parseFloat(selectedTradeInModelPrice.dataset.maxValue);

            const variantPrice = parseFloat(variantInfo.dataset.price);
            const priceToCompute = variantInfo.querySelector('.price-to-compute');

            priceToCompute.querySelector('.min-price').innerHTML = variantPrice - minValue;
            priceToCompute.querySelector('.max-price').innerHTML = variantPrice - maxValue;
          } else {
            variantInfo.classList.add('hidden');
          }
        });
      });
    });
  }
};

export { tradeInForm };
