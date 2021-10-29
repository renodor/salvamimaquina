const cartForm = () => {
  const cartForm = document.querySelector('#cart-form > form');

  if (cartForm) {
    Array.from(cartForm.elements).forEach((formElement) => {
      formElement.addEventListener('change', (event) => {
        // If on mobile get products sorting form mobile data, otherwise get products sorting form desktop data
        const formData = new FormData(cartForm);
        const queryString = new URLSearchParams(formData);
        queryString.append('option_type', event.currentTarget.name);
        queryString.append('option_value', event.currentTarget.value);

        fetch(`/products/product_variants_with_option_values?${queryString}`, { method: 'POST', headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then((data) => console.log(data));
      });
    });
  }
};

export { cartForm };
