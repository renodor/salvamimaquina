import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    setTimeout(() => {
      this.remove();
    }, 10000);
  }

  remove() {
    this.element.remove()
  }
}