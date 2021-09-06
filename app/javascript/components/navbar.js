// method to open/close the sidebar cart
const navbar = () => {
  const navbarTogglers = document.querySelectorAll('.navbar-toggler');
  const navbarCollapse = document.querySelector('.navbar-collapse');

  // listen clicks on the navbar toggle and open the navbar when clicked
  navbarTogglers.forEach((navbarToggler) => {
    navbarToggler.addEventListener('click', () => {
      navbarCollapse.classList.toggle('active');
    });
  });
};

export { navbar };
