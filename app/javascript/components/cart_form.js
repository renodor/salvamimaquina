const cartForm = () => {
  const cartForm = document.querySelector('#cart-form > form');

  if (cartForm) {
    Array.from(cartForm.elements).forEach((formElement) => {
      formElement.addEventListener('change', (event) => {
        // If on mobile get products sorting form mobile data, otherwise get products sorting form desktop data
        const formData = new FormData(cartForm);
        const queryString = new URLSearchParams(formData);
        queryString.append('option_type', event.currentTarget.name.replace('option_type_', ''));
        queryString.append('option_value', event.currentTarget.value);

        fetch(`/products/product_variants_with_option_values?${queryString}`, { method: 'POST', headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then((data) => {
              Object.entries(data.option_values_by_option_type).forEach((optionType) => {
                const formSelect = cartForm.elements[`option_type_${optionType[0]}`];
                if (formSelect) {
                  Array.from(formSelect.options).forEach((formSelectOption) => {
                    formSelectOption.disabled = !optionType[1].includes(parseInt(formSelectOption.value));
                  });
                }
              });
            });
      });
    });
  }
};

export { cartForm };
