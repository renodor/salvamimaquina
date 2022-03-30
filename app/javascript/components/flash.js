// Remove flash when clicking on cross and auto remove it after 10 seconds
const flash = () => {
  const flash = document.querySelector('.flash');

  if (flash) {
    flash.querySelector('svg.close-flash').addEventListener('click', () => {
      flash.remove();
    });

    setTimeout(() => {
      flash.remove();
    }, 10000);
  }
};

export { flash };
