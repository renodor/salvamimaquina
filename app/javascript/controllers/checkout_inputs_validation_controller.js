import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Not really the "stimulus" way of doing things, but easier for not to select all inputs, selects and textareas...
    const inputs = this.element.querySelectorAll('input, select, textarea');
    inputs.forEach((input) => {
      input.addEventListener('invalid', () => {
        input.classList.add('error');
      });

      input.addEventListener('blur', () => {
        if (input.checkValidity()) {
          input.classList.remove('error');
        }
      });
    });
  }
}
