// Add the given flash (html tag as a string) to the DOM, and then add dynamism to it
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

addDinamysmToFlash()

export { addFlashToDom, addDinamysmToFlash };