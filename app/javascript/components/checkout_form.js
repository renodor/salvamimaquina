const checkout = document.getElementById('checkout');

if (checkout) {
  const inputs = checkout.querySelectorAll('input, select, textarea');
  inputs.forEach((input) => {
    input.addEventListener('invalid', (event) => {
      input.classList.add('error');
    });

    input.addEventListener('blur', (event) => {
      if (input.checkValidity()) {
        input.classList.remove('error');
      }
    });
  });
}