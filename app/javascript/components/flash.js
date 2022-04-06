// Add the given flash (html tag as a string) to the DOM, and then add dynamism to it
// This method is a bit special, indeed instead of being imported in application.js,
// it is imported in other modules when we need to add a flash after an ajax request (ex: add_to_cart.js)
const addFlashToDom = (flash) => {
  const content = document.querySelector('body #wrapper #content');
  content.insertAdjacentHTML('afterbegin', flash);
  addDinamysmToFlash();
};

// Remove flash when clicking on cross and auto remove it after 10 seconds
// (is imported in application.js, so it will be called automatically when page load,
// and is also called by addFlashToDom() when needed)
const addDinamysmToFlash = () => {
  const flash = document.querySelector('.flash');

  if (flash) {
    flash.querySelector('svg.close-flash').addEventListener('click', () => (flash.remove()));

    setTimeout(() => {
      flash.remove();
    }, 10000);
  }
};

export { addFlashToDom, addDinamysmToFlash };
