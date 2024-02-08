import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const productsSearcherForm = document.querySelector('form#products-filters-form');

    // On mobile we display the number of selected filters (on the filters modal trigger, and erase filter button)
    // This method update filters count each time a filter is added/removed
    const updateFilterCount = (formDataEntries) => {
      const priceRangeSlider = productsSearcherForm.querySelector('.price-range-slider .slider input');

      if (!priceRangeSlider) { return; }

      let count = 0;
      const priceRangeSlideMinMax = [priceRangeSlider.min, priceRangeSlider.max];

      // Loop over all filters to determine if we count it or not.
      // Indeed, we don't count "sorting", and we count price range only if they have been used (if the values are different from the original min and max values)
      for (const [key, value] of formDataEntries) {
        if (key === 'search[price_between][]') {
          if (!priceRangeSlideMinMax.includes(value)) {
            count += 1;
          }
        } else if (key.startsWith('search')) {
          count += 1;
        }
      }

      const filterCounts = document.querySelectorAll('#products-sidebar .filter-count');
      filterCounts.forEach((filterCount) => {
        filterCount.innerHTML = count > 0 ? `(${count})` : '';
      });
    };
  }

  inputChanged({ currentTarget }) {
    currentTarget.form.requestSubmit()
  }
}
