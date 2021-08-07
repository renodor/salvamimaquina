const productFilter = () => {
  const sidebarProductSearch = document.getElementById('sidebar_products_search');

  if (sidebarProductSearch) {
    sidebarProductSearch.addEventListener('submit', (event) => {
      const formData = new FormData(sidebarProductSearch);
      const queryString = new URLSearchParams(formData).toString();

      fetch(`/t/brands/apple/iphone?${queryString}`, { headers: { 'accept': 'application/json' } })
          .then((response) => response.json())
          .then((products) => {
            updateProducts(products);
            // TODO: update url params (without reloading the page), so that if user refresh or share link it won't loose filters
          });
    });

    const updateProducts = (products) => {
      const productList = document.getElementById('products');
      productList.innerHTML = '';
      products.forEach((product) => {
        productList.insertAdjacentHTML('beforeend', productCardHtml(product));
      });
    };

    const productCardHtml = (product) => {
      return `
      <li id=\"product_${product.id}\" class="columns three" data-hook="products_list_item" itemscope itemtype="http://schema.org/Product">
        <div class="product-image">
          <a href="#">IMAGE</a>
        </div>
        <a href=${product.url} class="info" itemprop="name" title=${product.name}>${product.name}</a>
        <span itemprop="offers" itemscope itemtype="http://schema.org/Offer">
          ${product.cheapest_variant_onsale ? discountPriceHtml(product.discount_price, product.discount_price_html_tag) : ''}
          <span class="price selling ${product.cheapest_variant_onsale ? 'crossed' : ''} itemprop="price" content="${product.price}">
            ${product.price_html_tag}
          </span>
        </span>
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
  };
};

export { productFilter };
