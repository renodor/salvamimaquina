import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const currentProductsSorting = document.getElementById('current-products-sorting');
    const productsSortingOptions = document.querySelectorAll('.products-sorting-option input');

    productsSortingOptions.forEach((productsSortingOption) => {
      productsSortingOption.addEventListener('change', (event) => {
        const selectedSortingKey = event.currentTarget.value;
        productsSortingOptions.forEach((option) => option.classList.remove('selected'));
        document.querySelectorAll(`input[value=${selectedSortingKey}]`).forEach((selectedSortingInput) => {
          selectedSortingInput.checked = true;
          // we need this .selected class because the default :checked css selector does not work properly,
          // because those inputs are displayed 2 times on the same page, so we have 2 inputs with the same id...
          selectedSortingInput.classList.add('selected');
        });

        currentProductsSorting.innerHTML = event.currentTarget.dataset.label;
      });
    });
  }
}
