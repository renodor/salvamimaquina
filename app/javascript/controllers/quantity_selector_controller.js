import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantityInput", "addQuantity", "removeQuantity"]

  addQuantity() {
    this.changeQuantity(parseInt(this.quantityInputTarget.value) + 1);
  }

  removeQuantity() {
    this.changeQuantity(parseInt(this.quantityInputTarget.value) - 1);
  }

  changeQuantity = (newQuantity) => {
    const totalStock = parseInt(this.quantityInputTarget.dataset.totalStock);
    if (totalStock === 1 || totalStock === 0) {
      this.quantityInputTarget.value = 1;
    } else if (newQuantity <= 1) {
      this.quantityInputTarget.value = 1;
      this.removeQuantityTarget.classList.add('disabled');
      this.addQuantityTarget.classList.remove('disabled');
    } else {
      if (newQuantity >= totalStock) {
        this.quantityInputTarget.value = totalStock;
        this.addQuantityTarget.classList.add('disabled');
        this.removeQuantityTarget.classList.remove('disabled');
      } else {
        this.quantityInputTarget.value = newQuantity;
        this.addQuantityTarget.classList.remove('disabled');
      }
      this.removeQuantityTarget.classList.remove('disabled');
    }
  };
}

if (false) {
  addQuantityTrigger.addEventListener('click', (_event) => {
    changeQuantity(parseInt(quantityInput.value) + 1);
  });

  removeQuantityTrigger.addEventListener('click', (_event) => {
    changeQuantity(parseInt(quantityInput.value) - 1);
  });

  quantityInput.addEventListener('change', (_event) => {
    let selectedQuantity = parseInt(quantityInput.value);
    selectedQuantity = isNaN(selectedQuantity) ? 1 : selectedQuantity;
    changeQuantity(selectedQuantity);
  });
}