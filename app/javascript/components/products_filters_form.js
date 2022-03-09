// Update product grid with the relevant products when a products filter (or sorting) is selected
const productsFiltersForm = () => {
  const productsSearcherForm = document.querySelector('form#products-filters-form');

  if (productsSearcherForm) {
    // HTML of a product card
    const productCardHtml = (product) => {
      return `
        <li id=\"product_${product.id}\" data-hook="products_list_item" itemscope itemtype="http://schema.org/Product">
          <div class="product-image">
            <img src="${product.image_url}">
          </div>
          <div class="product-name">${product.name}</div>
          <span class="prices" itemprop="offers" itemscope itemtype="http://schema.org/Offer">
            ${product.cheapest_variant_onsale ? discountPriceHtml(product.discount_price, product.discount_price_html_tag) : ''}
            <span class="price selling ${product.cheapest_variant_onsale ? 'crossed' : ''} itemprop="price" content="${product.price}">
              ${product.price_html_tag}
            </span>
          </span>
          <a href=${product.url} class="product-link full-absolute" itemprop="name" title=${product.name}></a>
        </li >
      `;
    };

    // HTML of a discount price to display if a product is on sale
    const discountPriceHtml = (discountPrice, discountPriceHtmlTag) => {
      return `
        <span class="price selling" itemprop="price" content="${discountPrice}">
          ${discountPriceHtmlTag}
        </span >
      `;
    };

    // To display if no products are found
    const displayNoProductsMessage = (noProductMessage) => {
      document.getElementById('products').innerHTML = `
        <div>
          ${noProductMessage}
        </div>
      `;
    };

    // Display all newly found products
    const updateProducts = (products) => {
      const productsGrid = document.getElementById('products');
      productsGrid.innerHTML = '';
      products.forEach((product) => {
        productsGrid.insertAdjacentHTML('beforeend', productCardHtml(product));
      });
    };

    // On mobile we display the number of selected filters (on the filters modal trigger, and erase filter button)
    // This method update filters count each time a filter is added/removed
    const updateFilterCount = (formDataEntries) => {
      let count = 0;
      const priceRangeSlider = productsSearcherForm.querySelector('.price-range-slider .slider input');
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

    // Fetch products each time a filter change. (We don't wait for form submission)
    [...productsSearcherForm.elements].forEach((input) => {
      input.addEventListener('change', () => {
        const formData = new FormData(productsSearcherForm);
        const queryString = new URLSearchParams(formData);

        // The searchKeywords is not part of the products filters form (its part of the products search form),
        // but needs to be added here in case users refine search results with filters
        const searchKeywordsQuery = new URLSearchParams(window.location.search).get('keywords');
        if (searchKeywordsQuery) { queryString.set('keywords', searchKeywordsQuery); }

        // Fetch new products from those form data
        fetch(`/products/filter?${queryString.toString()}`, { headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then(({ products, noProductsMessage }) => {
              products.length === 0 ? displayNoProductsMessage(noProductsMessage) : updateProducts(products);
            });

        updateFilterCount(formData.entries());
      });
    });
  }
};

export { productsFiltersForm };
