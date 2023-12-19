import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  handleInput() {
    console.log(this.element.value)
  }
}
