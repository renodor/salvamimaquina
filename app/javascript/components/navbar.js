// method to open/close the navbar on mobile
const navbar = () => {
  const navbarTogglers = document.querySelectorAll('.navbar-toggler');
  const navbarCollapse = document.querySelector('.navbar-collapse');
  const body = document.querySelector('body');

  // listen clicks on the navbar toggle and open the navbar when clicked
  navbarTogglers.forEach((navbarToggler) => {
    navbarToggler.addEventListener('click', () => {
      if (navbarCollapse.classList.contains('active')) {
        navbarCollapse.classList.remove('active');
        document.querySelector('.content-overlay').remove();
        body.classList.remove('overflow-hidden');
      } else {
        body.classList.add('overflow-hidden');
        const contentOverlay = document.createElement('div');
        contentOverlay.classList.add('content-overlay');
        body.appendChild(contentOverlay);
        navbarCollapse.classList.add('active');
      }
    });
  });
};

export { navbar };
