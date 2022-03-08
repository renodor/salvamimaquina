
const productSorting = () => {
  // There are actually 2 products sortings. So this selector will get the first one,
  // it is enough to know if we should execute this script or not
  // (But we won't use it later in the script because we need to work with both forms)
  const productsSorting = document.querySelector('.products-sorting');

  if (productsSorting) {
    const productsSortingToggle = document.getElementById('current-product-sorting');
    const productsSortingOptions = document.querySelectorAll('.products-sorting-option input');

    // Set product sorting displayed text regarding what sorting is currently applied
    productsSortingOptions.forEach((productsSortingOption) => {
      productsSortingOption.addEventListener('change', (event) => {
        const selectedSortingKey = event.currentTarget.value;
        productsSortingOptions.forEach((option) => option.classList.remove('selected'));
        document.querySelectorAll(`input[value=${selectedSortingKey}]`).forEach((selectedSortingInput) => {
          selectedSortingInput.checked = true;
          selectedSortingInput.classList.add('selected');
        });

        productsSortingToggle.innerHTML = event.currentTarget.dataset.label;
      });
    });
  };
};

export { productSorting };
