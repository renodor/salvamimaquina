// Set product sorting displayed text regarding what sorting is currently applied
const productSorting = () => {
  const productsSorting = document.getElementById('products-sorting');

  if (productsSorting) {
    const productsSortingToggle = productsSorting.querySelector('#products-sorting-toggle');
    const productsSortingForm = productsSorting.querySelector('#products-sorting-form');

    Array.from(productsSortingForm.elements).forEach((formElement) => {
      formElement.addEventListener('change', (event) => {
        // Each time a new sorting is selected, get the data of the product sorting form
        // with the currently selected input we retrieve the input node element, which contains its label in a dataset
        const selectedSorting = new FormData(productsSortingForm).get('sort_products');
        const selectedSortingLabel = productsSortingForm.querySelector(`input#${selectedSorting}`).dataset.label;
        productsSortingToggle.innerHTML = selectedSortingLabel;
      });
    });
  };
};

export { productSorting };
