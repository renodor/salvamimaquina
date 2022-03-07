// Adapt product filters modal on mobile/desktop views
const productsSidebar = () => {
  const productsSidebar = document.getElementById('products-sidebar');

  if (productsSidebar) {
    const body = document.querySelector('body');
    const productsSidebarContent = productsSidebar.querySelector('#products-sidebar-content');
    const showProductsSidebarContent = productsSidebar.querySelector('#show-products-sidebar-content');
    const hideProductsSidebarContent = productsSidebar.querySelector('#hide-products-sidebar-content');

    const setProductsSidebar = () => {
      if (window.innerWidth > 767) {
        productsSidebarContent.classList.remove('mobile');
        productsSidebarContent.classList.remove('show');
      } else {
        productsSidebarContent.classList.add('mobile');
        body.classList.remove('overflow-hidden');
      }
    };

    window.addEventListener('resize', () => {
      setProductsSidebar();
    });

    setProductsSidebar();

    showProductsSidebarContent.addEventListener('click', () => {
      productsSidebarContent.classList.add('show');
      body.classList.add('overflow-hidden');
    });

    hideProductsSidebarContent.addEventListener('click', () => {
      productsSidebarContent.classList.remove('show');
      body.classList.remove('overflow-hidden');
    });

    //   // Add/remove bootstrap modal classes regarding if we are on desktop or mobile
    //   // + force modal div to show/hidex regarding if we are on desktop or mobile
    //   // (On mobile we let bootstrap modal mechanism work normally, on desktop we always show the modal)
    //   const productsSidebar = () => {
    //     if (window.innerWidth > 767) {
    //       productFiltersModal.style.display = 'block';
    //       productFiltersModal.classList.remove('modal', 'fade');
    //     } else {
    //       productFiltersModal.classList.add('modal', 'fade');
    //       productFiltersModal.style.display = 'none';
    //     }
    //   };

    //   toggleProductFiltersModalClasses();

    //   // Bootstrap JS hook called when a modal is fully closed
    //   // We need it because the process of closing a modal is "asynchronous"...
    //   // So if we don't use this hook, toogleProductFiltersModalClasses will be called too early
    //   // (In line 39, 40 toogleProductFiltersModalClasses will maybe be called 2 times in a row,
    //   // but it is needed if modal is open and windows is resized)
    //   document.getElementById('productFiltersModal').addEventListener('hidden.bs.modal', () => {
    //     toggleProductFiltersModalClasses();
    //   });

    //   // When page is resized (can happen when user put device horizontally/vertically),
    //   // Close the product filter modal
    //   // Then call toggleProductFiltersModalClasses();
    //   // And if we are on desktop view makes sure that the correct tab stays open
    //   // (the ones with product filters and not with products sorting)
    //   const controller = new AbortController();
    //   window.addEventListener('resize', () => {
    //     if (document.querySelector('.products-sorting')) {
    //       $('#productFiltersModal').modal('hide');
    //       toggleProductFiltersModalClasses();
    //       if (window.innerWidth > 767) {
    //         const productFiltersAndSortingTab = document.getElementById('productFiltersAndSortingTab');
    //         productFiltersAndSortingTab.querySelector('#products-sorting-tab').classList.remove('active');
    //         productFiltersAndSortingTab.querySelector('#product-filters-tab').classList.add('active');

  //         const productFiltersAndSortingTabContent = document.getElementById('productFiltersAndSortingTabContent');
  //         productFiltersAndSortingTabContent.querySelector('#product-filters-tab-content').classList.add('active', 'show');
  //         productFiltersAndSortingTabContent.querySelector('#products-sorting-tab-content').classList.remove('active', 'show');
  //       }
  //     } else {
  //       // Removes this event listener if we are not on the product index anymore
  //       controller.abort();
  //     }
  //   }, { signal: controller.signal });
  }
};

export { productsSidebar };
