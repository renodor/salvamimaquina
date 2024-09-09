import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "colorInput", "priceInput"]

  inputChanged({ currentTarget }) {
    // Update filters count
    const label = this.labelTargets.find((label) => label.htmlFor === currentTarget.id)
    if (label) {
      label.dataset.selected = !(label.dataset.selected === 'true')
    }

    let appliedFiltersCount = this.labelTargets.filter((label) => label.dataset.selected === 'true').length
    appliedFiltersCount += this.priceInputTargets.filter((input) => ![input.min, input.max].includes(input.value)).length
    const filterCountText = appliedFiltersCount > 0 ? `(${appliedFiltersCount})` : ''

    document.querySelector("#filter-count-button").innerText = filterCountText
    document.querySelector("#filter-count-menu").innerText = filterCountText

    // Adds related inputs to the form submission
    const relatedIds = JSON.parse(currentTarget.dataset.relatedIds || "[]")

    if (relatedIds.length > 0) {
      this.colorInputTargets.forEach((input) => {
        if (relatedIds.includes(parseInt(input.value))) {
          input.checked = currentTarget.checked
        }
      })
    }

    currentTarget.form.requestSubmit()
  }
}
