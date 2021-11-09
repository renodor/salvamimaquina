const quantitySelector = () => {
  const quantitySelector = document.querySelector('.quantity-selector');

  if (quantitySelector) {
    const quantityInput = quantitySelector.querySelector('input');
    const addQuantityTrigger = quantitySelector.querySelector('span[data-type="add"');
    const removeQuantityTrigger = quantitySelector.querySelector('span[data-type="remove"');

    const changeQuantity = (newQuantity) => {
      const totalStock = parseInt(quantityInput.dataset.totalStock);
      if (totalStock === 1 || totalStock === 0) {
        quantityInput.value = 1;
      } else if (newQuantity <= 1) {
        quantityInput.value = 1;
        removeQuantityTrigger.classList.add('disabled');
        addQuantityTrigger.classList.remove('disabled');
      } else {
        if (newQuantity >= totalStock) {
          quantityInput.value = totalStock;
          addQuantityTrigger.classList.add('disabled');
          removeQuantityTrigger.classList.remove('disabled');
        } else {
          quantityInput.value = newQuantity;
          addQuantityTrigger.classList.remove('disabled');
        }
        removeQuantityTrigger.classList.remove('disabled');
      }
    };

    addQuantityTrigger.addEventListener('click', (_event) => {
      changeQuantity(parseInt(quantityInput.value) + 1);
    });

    removeQuantityTrigger.addEventListener('click', (_event) => {
      changeQuantity(parseInt(quantityInput.value) - 1);
    });

    quantityInput.addEventListener('change', (_event) => {
      let selectedQuantity = parseInt(quantityInput.value);
      selectedQuantity = isNaN(selectedQuantity) ? 1 : selectedQuantity;
      changeQuantity(selectedQuantity);
    });
  }
};

export { quantitySelector };
