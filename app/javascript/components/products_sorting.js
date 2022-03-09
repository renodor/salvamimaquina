// Set product sorting displayed text regarding what sorting is currently applied
const productsSorting = () => {
  // There are actually 2 products sortings. So this selector will get the first one,
  // it is enough to know if we should execute this script or not
  // (But we won't use it later in the script because we need to work with both forms)
  const productsSorting = document.querySelector('.products-sorting');

  if (productsSorting) {
    const currentProductsSorting = document.getElementById('current-products-sorting');
    const productsSortingOptions = document.querySelectorAll('.products-sorting-option input');

    productsSortingOptions.forEach((productsSortingOption) => {
      productsSortingOption.addEventListener('change', (event) => {
        const selectedSortingKey = event.currentTarget.value;
        productsSortingOptions.forEach((option) => option.classList.remove('selected'));
        document.querySelectorAll(`input[value=${selectedSortingKey}]`).forEach((selectedSortingInput) => {
          selectedSortingInput.checked = true;
          // we need this selected class because the default :checked css selector does not work properly,
          // because those inputes are displayed 2 times on the same page, so we have 2 inputs with the same id...
          selectedSortingInput.classList.add('selected');
        });

        currentProductsSorting.innerHTML = event.currentTarget.dataset.label;
      });
    });
  };
};

export { productsSorting };
