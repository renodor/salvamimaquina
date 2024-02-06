import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "imageInput",
    "imagePreview"
  ]

  imageChanged({ currentTarget }) {
    const imagePreview = this.imagePreviewTargets.find((imagePreview) => imagePreview.dataset.id == currentTarget.dataset.id)
    if (currentTarget.files.length > 0) {
      const reader = new FileReader();
      reader.onload = ({ currentTarget }) => { imagePreview.src = currentTarget.result };
      reader.readAsDataURL(currentTarget.files[0]);
      imagePreview.classList.remove('display-none');
    }
  }
}
