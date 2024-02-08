import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    variantId: String
  }

  static targets = [
    "itempropUrl"
  ]

  // This controller is re-rendered everytime user select a new variant on product show
  // so we use it to update variant_id URL param, and itemprop Url HTML tag
  connect() {
    const url = new URL(window.location);
    url.searchParams.set('variant_id', this.variantIdValue);
    history.replaceState(history.state, '', url);
    this.itempropUrlTarget.content = url
  }
}
