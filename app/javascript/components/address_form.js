const addressForm = () => {
  Spree.ready(function ($) {
    const stateField = document.querySelector('#sstate')
    if (stateField) {
      const panamaStateId = stateField.dataset.panamaStateId
      stateField.querySelector('select').addEventListener('change', (event) => {
        const stateId = event.currentTarget.value
        $.get(
          Spree.pathFor('api/districts'), {
            state_id: stateId
          },
          function (data) {
            console.log(data)
          }
        );
      })
    }
  })
}

export { addressForm }