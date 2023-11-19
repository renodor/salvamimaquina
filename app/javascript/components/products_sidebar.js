const productsSidebar = document.getElementById('products-sidebar');

if (productsSidebar) {
  const body = document.querySelector('body');
  const productsSidebarContent = productsSidebar.querySelector('#products-sidebar-content');
  const showProductsSidebarContentBtn = productsSidebar.querySelector('#show-products-sidebar-content');
  const hideProductsSidebarContentBtns = productsSidebar.querySelectorAll('.hide-products-sidebar-content');

  // Add bootstrap tab classes to show the products filters tab by default
  // (and hide the products sorting tab)
  const displayFilterTab = () => {
    const filterTabId = 'product-filters-tab';
    const sortingTabId = 'products-sorting-tab';
    const productsFilterTabBtn = productsSidebar.querySelector(`#${filterTabId}`);
    const productsSortingTabBtn = productsSidebar.querySelector(`#${sortingTabId}`);
    const productsFilterTabContent = productsSidebar.querySelector(`#${filterTabId}-content`);
    const productsSortingTabContent = productsSidebar.querySelector(`#${sortingTabId}-content`);

    productsFilterTabBtn.classList.add('active');
    productsFilterTabBtn.ariaSelected = true;
    productsSortingTabBtn.classList.remove('active');
    productsSortingTabBtn.ariaSelected = false;

    productsFilterTabContent.classList.add('active', 'show');
    productsSortingTabContent.classList.remove('active', 'show');
  };

  // On desktop, show the products sidebar,
  // on mobile show the products filters and sorting modal
  const setProductsSidebar = () => {
    if (window.innerWidth > 767) {
      productsSidebarContent.classList.remove('mobile');
      productsSidebarContent.classList.remove('show');
    } else {
      productsSidebarContent.classList.add('mobile');
      body.classList.remove('overflow-hidden');
      displayFilterTab();
    }
  };

  window.addEventListener('resize', () => {
    setProductsSidebar();
  });

  setProductsSidebar();

  // Button that opens the products filters and sorting modal
  showProductsSidebarContentBtn.addEventListener('click', () => {
    body.classList.add('overflow-hidden', 'position-relative');
    const contentOverlay = document.createElement('div');
    contentOverlay.classList.add('content-overlay');
    body.appendChild(contentOverlay);
    productsSidebarContent.classList.add('show');
  });

  // Buttons that hide the products filters and sorting modal
  hideProductsSidebarContentBtns.forEach((hideProductsSidebarContentBtn) => {
    hideProductsSidebarContentBtn.addEventListener('click', () => {
      productsSidebarContent.classList.remove('show');
      document.querySelector('.content-overlay').remove();
      body.classList.remove('overflow-hidden', 'position-relative');
    });
  });
}