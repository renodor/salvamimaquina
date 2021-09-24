// Add/remove bootstrap modal classes on product filters to enable/disable the modal regarding screen size
const productFiltersModal = () => {
  const productFiltersModalContainer = document.getElementById('product-filters-modal');

  if (productFiltersModalContainer) {
    const productFiltersModal = productFiltersModalContainer.querySelector('#productFiltersModal');

    const toggleProductFiltersModalClasses = () => {
      if (window.innerWidth > 767) {
        productFiltersModal.classList.remove('modal', 'fade');
        productFiltersModal.style.display = 'block';
      } else {
        productFiltersModal.style.display = 'none';
        productFiltersModal.classList.add('modal', 'fade');
      }
    };

    toggleProductFiltersModalClasses();
    window.addEventListener('resize', toggleProductFiltersModalClasses);
  }
};

export { productFiltersModal };
