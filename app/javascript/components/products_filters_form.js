const productsFiltersForm = () => {
  const productsSearcherForm = document.querySelector('form#products-filters-form');

  if (productsSearcherForm) {
    // HTML of a product card to display on front end
    const productCardHtml = (product, index) => {
      return `
        <li id=\"product_${product.id}\" data-hook="products_list_item" itemscope itemtype="http://schema.org/Product">
          <div class="product-image">
            ${productImageHtml(product.image_url)}
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

    // HTML of a product image
    const productImageHtml = (imageUrl) => {
      if (imageUrl) {
        return `<img src="${imageUrl}">`;
      } else {
        return '<div class="image-placeholder" style="width: 200px; height: 200px"></div>'; // TODO: use cloudinary fallback default image instead
      }
    };

    // To display if no products are found
    const displayNoProductsMessage = (noProductMessage) => {
      document.getElementById('products').innerHTML = `
        <div data-hook="products_search_results_heading_no_results_found">
          ${noProductMessage}
        </div>
      `;
    };

    // Display all newly found products
    const updateProducts = (products) => {
      const productList = document.getElementById('products');
      productList.innerHTML = '';
      products.forEach((product, index) => {
        productList.insertAdjacentHTML('beforeend', productCardHtml(product, index));
      });
    };

    const updateFilterCount = (formDataEntries) => {
      let count = 0;
      const priceRangeSlider = productsSearcherForm.querySelector('.price-range-slider .slider input');
      const priceRangeSlideMinMax = [priceRangeSlider.min, priceRangeSlider.max];
      for (const [key, value] of formDataEntries) {
        if (key === 'search[price_between][]' && !priceRangeSlideMinMax.includes(value)) {
          count += 1;
        } else if (key.startsWith('search') && key != 'search[price_between][]') {
          count += 1;
        }
      }

      const filterCounts = document.querySelectorAll('#products-sidebar .filter-count');
      filterCounts.forEach((filterCount) => {
        if (count > 0) {
          filterCount.innerHTML = `(${count})`;
        } else {
          filterCount.innerHTML = '';
        }
      });
    };

    [...productsSearcherForm.elements].forEach((input) => {
      input.addEventListener('change', () => {
        const formData = new FormData(productsSearcherForm);
        const queryString = new URLSearchParams(formData);
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
