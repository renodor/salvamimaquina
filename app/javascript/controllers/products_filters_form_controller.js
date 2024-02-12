import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  inputChanged({ currentTarget }) {
    const form = currentTarget.form
    const formData = new FormData(form)
    const searchParams = new URLSearchParams(formData)
    debugger
    const url = new URL(location)
    searchParams.forEach((value, key) => {
      debugger
      // url.searchParams.set('variant_id', variantId)
    })
    currentTarget.form.requestSubmit()
  }
}
