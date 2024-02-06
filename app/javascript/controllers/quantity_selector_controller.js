import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["quantityInput", "addQuantity", "removeQuantity"]

  addQuantity() {
    this.quantityChanger(parseInt(this.quantityInputTarget.value) + 1);
  }

  removeQuantity() {
    this.quantityChanger(parseInt(this.quantityInputTarget.value) - 1);
  }

  changeQuantity() {
    let selectedQuantity = parseInt(this.quantityInputTarget.value);
    selectedQuantity = isNaN(selectedQuantity) ? 1 : selectedQuantity;
    this.quantityChanger(selectedQuantity);
  }

  quantityChanger(newQuantity) {
    const totalStock = parseInt(this.quantityInputTarget.dataset.totalStock);
    if ([0, 1].includes(totalStock)) {
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