// This module will refresh products on product grid regarding what product filter and product order is selected
const productFilters = () => {
  const sidebar = document.getElementById('sidebar');

  if (sidebar) {
    // Get product filter form
    const productsFiltersForm = document.querySelector('#sidebar-products-filter');

    // Get products sorting forms
    const productsSortingFormDesktop = document.querySelector('.products-sorting-form.desktop');
    const productsSortingFormMobile = document.querySelector('.products-sorting-form.mobile');

    // Get products search form
    const productsSearchForm = document.querySelector('#products-search');

    // Fetch new products each time a product filter or a product sort is selected
    [productsFiltersForm, productsSortingFormDesktop, productsSortingFormMobile, productsSearchForm].forEach((form) => {
      Array.from(form.elements).forEach((formElement) => {
        formElement.addEventListener('change', (event) => {
          fetchProductsfromFormData();
        });
      });
    });

    const fetchProductsfromFormData = () => {
      // If on mobile get products sorting form mobile data, otherwise get products sorting form desktop data
      const productsSortingFormData = new FormData(window.innerWidth <= 767 ? productsSortingFormMobile : productsSortingFormDesktop);

      // Get product filter form data
      const productFiltersFormData = new FormData(productsFiltersForm);

      // Get products search form data
      const productsSearchFormData = new FormData(productsSearchForm);

      // Build query string from product filter form data, product sort form data, and products search form data
      const queryString = new URLSearchParams(productFiltersFormData);
      queryString.append('sort_products', productsSortingFormData.get('sort_products'));
      queryString.append('search_products', productsSearchFormData.get('keywords'));

      for (const [key, value] of queryString) { console.log(key, value) }

      // Fetch new products from those form data
      fetch(`/t/filter_products?${queryString.toString()}`, { headers: { 'accept': 'application/json' } })
          .then((response) => response.json())
          .then(({ products, noProductsMessage }) => {
            products.length === 0 ? displayNoProductsMessage(noProductsMessage) : updateProducts(products);
            // TODO: update url params (without reloading the page), so that if user refresh or share link it won't loose filters
          });
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
  };
};

export { productFilters };
