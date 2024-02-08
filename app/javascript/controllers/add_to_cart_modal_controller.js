import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    displayModal: Boolean
  }

  connect() {
    if (this.displayModalValue) {
      const myModal = new bootstrap.Modal(this.element);
      myModal.show();
    }
  }
}
