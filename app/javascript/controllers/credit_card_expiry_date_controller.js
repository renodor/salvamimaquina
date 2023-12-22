import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleInput(event) {
    if (event.data === null) { return }

    this.element.value = this.element.value.replace(/[^0-9+]/g, '')

    if (this.element.value.length === 2) {
      this.element.value = `${this.element.value} / `
    }
    // if (this.element.value.toString().length === 2) {
    //   this.element.value = `${this.element.value} / `
    // }
  }
}
