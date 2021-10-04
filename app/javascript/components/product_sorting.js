
const productSorting = () => {
  // There are actually 2 products sortings. So this selector will get the first one,
  // it is enough to know if we should execute this script or not
  // (But we won't use it later in the script because we need to work with both forms)
  const productsSorting = document.querySelector('.products-sorting');

  if (productsSorting) {
    const productsSortingToggle = document.querySelector('#products-sorting-toggle');
    const productsSortingForms = document.querySelectorAll('.products-sorting-form');

    // Set product sorting displayed text regarding what sorting is currently applied
    productsSortingForms.forEach((productsSortingForm) => {
      Array.from(productsSortingForm.elements).forEach((formElement) => {
        formElement.addEventListener('change', (event) => {
          const selectedSortingKey = event.currentTarget.dataset.key;
          document.querySelectorAll(`input[data-key=${selectedSortingKey}]`).forEach((selectedSortingInput) => {
            selectedSortingInput.checked = true;
          });

          // Each time a new sorting is selected, get the data of the product sorting form
          // with the currently selected input we retrieve the input node element, which contains its label in a dataset
          const selectedSorting = new FormData(productsSortingForm).get('sort_products');
          const selectedSortingLabel = productsSortingForm.querySelector(`input[data-key=${selectedSorting}]`).dataset.label;
          productsSortingToggle.innerHTML = selectedSortingLabel;
        });
      });
    });

    // When page is resized (can happen when user put device horizontally/vertically),
    // makes sure that the product filter modal gray background disapear,
    // and makes sure that the correct tab stays open (the ones with product filters and not with products sorting)
    window.addEventListener('resize', (event) => {
      document.querySelector('.modal-backdrop.fade.show')?.remove();
      if (window.innerWidth > 767) {
        const productFiltersAndSortingTab = document.getElementById('productFiltersAndSortingTab');
        productFiltersAndSortingTab.querySelector('#products-sorting-tab').classList.remove('active', 'show');
        productFiltersAndSortingTab.querySelector('#product-filters-tab').classList.add('active', 'show');
        document.querySelector('#productFiltersAndSortingTabContent #product-filters-tab-content').classList.add('active', 'show');
      }
    });
  };
};

export { productSorting };
