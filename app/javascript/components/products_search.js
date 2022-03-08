const productsSearch = () => {
  const productsSearchModal = document.querySelector('#productsSearchModal');

  if (productsSearchModal) {
    productsSearchModal.addEventListener('shown.bs.modal', () => {
      productsSearchModal.querySelector('input#keywords').focus();
    });
  };
};

export { productsSearch };
