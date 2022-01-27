const tradeInForm = () => {
  const tradeInForm = document.getElementById('trade-in-form');

  if (tradeInForm) {
    const displayCorrectChildren = (parentId, children) => {
      children.forEach((childElement) => {
        if (childElement.dataset.parentId === parentId) {
          childElement.classList.remove('display-none');
          childElement.dataset.selected = true;
        } else {
          childElement.classList.add('display-none');
          childElement.dataset.selected = false;
        }
      });
    };

    const selectCategories = tradeInForm.querySelector('#trade_in_categories');
    selectCategories.addEventListener('change', (event) => {
      const tradeInModels = tradeInForm.querySelector('#trade-in-models');
      tradeInModels.classList.remove('hidden');
      displayCorrectChildren(event.currentTarget.value, tradeInModels.querySelectorAll('.trade-in-model'));
    });

    const selectModels = tradeInForm.querySelectorAll('#trade-in-models select');
    selectModels.forEach((selectModel) => {
      selectModel.addEventListener('change', (event) => {
        const tradeInModelPrices = tradeInForm.querySelector('#trade-in-model-prices');
        tradeInModelPrices.classList.remove('hidden');
        displayCorrectChildren(event.currentTarget.value, tradeInModelPrices.querySelectorAll('.trade-in-model-price'));
        tradeInForm.querySelector('#trade-in-second-part').classList.remove('hidden');
      });
    });

    const selectTaxon = tradeInForm.querySelector('#taxons select');
    selectTaxon.addEventListener('change', (event) => {
      const products = tradeInForm.querySelector('#products');
      products.classList.remove('hidden');
      displayCorrectChildren(event.currentTarget.value, products.querySelectorAll('.product'));
    });

    const selectProducts = tradeInForm.querySelectorAll('#products select');
    selectProducts.forEach((selectProduct) => {
      selectProduct.addEventListener('change', (event) => {
        const variants = tradeInForm.querySelector('#variants');
        variants.classList.remove('hidden');
        displayCorrectChildren(event.currentTarget.value, variants.querySelectorAll('.variant'));
      });
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
