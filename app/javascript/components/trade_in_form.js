const tradeInForm = () => {
  const tradeInForm = document.getElementById('trade-in-form');

  if (tradeInForm) {
    const selectInput = tradeInForm.querySelector('select');

    const displaySelectedTradeInModelPrices = (selectedTradeInModelId) => {
      tradeInForm.querySelectorAll('#trade-in-model-prices .trade-in-model-price').forEach((tradeInModelPrice) => {
        if (tradeInModelPrice.dataset.id == selectedTradeInModelId) {
          tradeInModelPrice.classList.remove('display-none');
        } else {
          tradeInModelPrice.classList.add('display-none');
        }
      });
    };

    selectInput.addEventListener('change', (event) => {
      displaySelectedTradeInModelPrices(event.currentTarget.value);
    });

    displaySelectedTradeInModelPrices(selectInput.value);
  }
};

export { tradeInForm };
