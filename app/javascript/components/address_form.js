const addressForm = () => {
  const addressForm = document.getElementById('checkout_form_address');

  if (addressForm) {
    // Update district lists regarding what state is selected
    // (Currently useless because only one state is available)
    const stateField = document.querySelector('#sstate');
    Spree.ready(function($) {
      stateField.querySelector('select').addEventListener('change', (event) => {
        const stateId = event.currentTarget.value;
        $.get(
            Spree.pathFor('api/districts'), {
              state_id: stateId
            },
            (data) => {
              const districtOptions = document.querySelector('#sdistrict select');
              if (data.districts.length) {
                districtOptions.innerHTML = data.districts.map((district) => `<option value="${district.id}">${district.name}</option>`).join('');
              } else {
                districtOptions.innerHTML = '';
              }
            }
        );
      });
    });

    const inputs = addressForm.querySelectorAll('input, select, textarea');
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
};

export { addressForm };
