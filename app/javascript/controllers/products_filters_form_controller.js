import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  inputChanged({ currentTarget }) {
    currentTarget.form.requestSubmit()
  }
}
