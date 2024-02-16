import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('ooo')
  }

  inputChanged({ currentTarget }) {
    console.log('hey')
    const form = currentTarget.form
    const formData = new FormData(form)
    const queryString = new URLSearchParams(formData).toString()
    const url = new URL(window.location);

    url.search = queryString
    window.history.pushState({ path: url.href }, '', url.href);

    currentTarget.form.requestSubmit()
  }
}
