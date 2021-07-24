const addressForm = () => {
  Spree.ready(function($) {
    const stateField = document.querySelector('#sstate');
    if (stateField) {
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
    }
  });
};

export { addressForm };
