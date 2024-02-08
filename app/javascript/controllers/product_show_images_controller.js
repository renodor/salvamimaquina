import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mainImage",
    "thumbnail"
  ]

  setAsMainImage({ currentTarget }) {
    this.mainImageTarget.src = currentTarget.dataset.imageUrl

    this.thumbnailTargets.forEach((thumbnail) => {
      if (thumbnail === currentTarget) {
        thumbnail.classList.add('selected')
      } else {
        thumbnail.classList.remove('selected')
      }
    })
  }
}
