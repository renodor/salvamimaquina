// method to open/close the navbar on mobile
const navbar = () => {
  const navbarTogglers = document.querySelectorAll('.navbar-toggler');
  const navbarCollapse = document.querySelector('.navbar-collapse');
  const body = document.querySelector('body');

  // listen clicks on the navbar toggle and open the navbar when clicked
  navbarTogglers.forEach((navbarToggler) => {
    navbarToggler.addEventListener('click', () => {
      navbarCollapse.classList.toggle('active');
      body.classList.toggle('overflow-hidden');
    });
  });
};

export { navbar };
