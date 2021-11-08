const quantitySelector = () => {
  const quantitySelector = document.querySelector('.quantity-selector');

  if (quantitySelector) {
    const variantIdInput = document.querySelector('#cart-form > form #variant_id');
    const quantityInput = quantitySelector.querySelector('input');
    let currentQuantity = parseInt(quantityInput.value);
    const addQuantityTrigger = quantitySelector.querySelector('span[data-type="add"');
    const removeQuantityTrigger = quantitySelector.querySelector('span[data-type="remove"');

    const addQuantity = (canSupply, canSupplyOneMore) => {
      if (canSupply) {
        quantityInput.value++;
        currentQuantity++;
        removeQuantityTrigger.classList.remove('disabled');
      }

      if (!canSupplyOneMore) {
        addQuantityTrigger.classList.add('disabled');
      }
    };

    const removeQuantity = () => {
      if (currentQuantity > 2) {
        addQuantityTrigger.classList.remove('disabled');
        quantityInput.value--;
        currentQuantity--;
      } else if (currentQuantity === 2) {
        quantityInput.value--;
        currentQuantity--;
        removeQuantityTrigger.classList.add('disabled');
      }
    };

    addQuantityTrigger.addEventListener('click', (_event) => {
      fetch(
          `/products/check_if_can_supply?variant_id=${variantIdInput.value}&quantity=${parseInt(quantityInput.value) + 1}`,
          { headers: { 'accept': 'application/json' } }
      )
          .then((response) => response.json())
          .then(({ canSupply, canSupplyOneMore }) => {
            addQuantity(canSupply, canSupplyOneMore);
          });
    });

    removeQuantityTrigger.addEventListener('click', (_event) => {
      removeQuantity();
    });

    quantityInput.addEventListener('change', (_event) => {
      const selectedQuantity = parseInt(quantityInput.value);

      if (selectedQuantity < 1) {
        quantityInput.value = currentQuantity;
      } else {
        fetch(
            `/products/check_if_can_supply?variant_id=${variantIdInput.value}&quantity=${selectedQuantity}`,
            { headers: { 'accept': 'application/json' } }
        )
            .then((response) => response.json())
            .then(({ canSupply, canSupplyOneMore }) => {
              if (canSupply) {
                currentQuantity = selectedQuantity;
                removeQuantityTrigger.classList.remove('disabled');
                if (canSupplyOneMore) {
                  addQuantityTrigger.classList.remove('disabled');
                } else {
                  addQuantityTrigger.classList.add('disabled');
                }
              } else {
                quantityInput.value = currentQuantity;
              }
            });
      }
    });
  }
};

export { quantitySelector };
