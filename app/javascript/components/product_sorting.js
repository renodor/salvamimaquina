
const productSorting = () => {
  // There are actually 2 products sortings. So this selector will get the first one,
  // it is enough to know if we should execute this script or not
  // (But we won't use it later in the script because we need to work with both forms)
  const productsSorting = document.querySelector('.products-sorting');

  if (productsSorting) {
    // const productsSortingItems = productsSorting.querySelector('.dropdown-item');
    // productsSortingItems.addEventListener('click', (event) => {

    // })

    // // Set product sorting displayed text regarding what sorting is currently applied
    // productsSortingForms.forEach((productsSortingForm) => {
    //   [...productsSortingForm.elements].forEach((formElement) => {
    //     formElement.addEventListener('change', (event) => {
    //       // const selectedSortingKey = event.currentTarget.dataset.key;
    //       // document.querySelectorAll(`input[data-key=${selectedSortingKey}]`).forEach((selectedSortingInput) => {
    //       //   selectedSortingInput.checked = true;
    //       // });

    //       // Each time a new sorting is selected, get the data of the product sorting form
    //       // with the currently selected input we retrieve the input node element, which contains its label in a dataset
    //       const selectedSorting = new FormData(productsSortingForm).get('sort_products');
    //       const selectedSortingLabel = productsSortingForm.querySelector(`input[data-key=${selectedSorting}]`).dataset.label;
    //       productsSortingToggle.innerHTML = selectedSortingLabel;
    //     });
    //   });
    // });
  };
};

export { productSorting };
