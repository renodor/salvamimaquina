const tradeInForm = () => {
  const tradeInForm = document.getElementById('trade-in-form');

  if (tradeInForm) {
    const selectCategories = tradeInForm.querySelector('#trade_in_categories');

    const displaySelectedTradeInModelPrices = (selectedTradeInModelId) => {
      tradeInForm.querySelectorAll('#trade-in-models select').forEach((tradeInModel) => {
        if (tradeInModel.id == selectedTradeInModelId) {
          tradeInModel.classList.remove('display-none');
        } else {
          tradeInModel.classList.add('display-none');
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
        tradeInForm.querySelectorAll('#trade-in-model-prices .trade-in-model-price').forEach((tradeInModelPrice) => {
          if (tradeInModelPrice.dataset.modelId == selectedModelId) {
            tradeInModelPrice.classList.remove('display-none');
          } else {
            tradeInModelPrice.classList.add('display-none');
          }
        });
      });
    });
  }
};

export { tradeInForm };
