const productFilter = () => {
  const sidebarProductSearch = document.getElementById('sidebar_products_search');

  if (sidebarProductSearch) {
    sidebarProductSearch.querySelectorAll('input').forEach((input) => {
      input.addEventListener('change', (event) => {
        const formData = new FormData(sidebarProductSearch);
        const queryString = new URLSearchParams(formData).toString();

        fetch(`/t/brands/apple/iphone?${queryString}`, { headers: { 'accept': 'application/json' } })
            .then((response) => response.json())
            .then(({ products, noProductsMessage }) => {
              products.length === 0 ? displayNoProductsMessage(noProductsMessage) : updateProducts(products);
            // TODO: update url params (without reloading the page), so that if user refresh or share link it won't loose filters
            });
      });
    });

    const displayNoProductsMessage = (noProductMessage) => {
      document.getElementById('products').innerHTML = `
        <div data-hook="products_search_results_heading_no_results_found">
          ${noProductMessage}
        </div>
      `;
    };

    const updateProducts = (products) => {
      const productList = document.getElementById('products');
      productList.innerHTML = '';
      products.forEach((product, index) => {
        productList.insertAdjacentHTML('beforeend', productCardHtml(product, index));
      });
    };

    const productCardHtml = (product, index) => {
      return `
        <li id=\"product_${product.id}\" class="columns three ${index === 0 ? 'alpha' : ''}" data-hook="products_list_item" itemscope itemtype="http://schema.org/Product">
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

    const discountPriceHtml = (discountPrice, discountPriceHtmlTag) => {
      return `
        <span class="price selling" itemprop="price" content="${discountPrice}">
          ${discountPriceHtmlTag}
        </span >
      `;
    };

    const productImageHtml = (imageUrl) => {
      if (imageUrl) {
        return `<img src="${imageUrl}">`;
      } else {
        return '<div class="image-placeholder" style="height: 300px;"></div>'; // TODO: import this component from controller
      }
    };
  };
};

export { productFilter };
