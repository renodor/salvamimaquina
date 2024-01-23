import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["navbarCollapse"]

  toggle() {
    const body = document.querySelector('body')
    if (this.navbarCollapseTarget.classList.contains('active')) {
      this.navbarCollapseTarget.classList.remove('active');
      document.querySelector('.content-overlay').remove();
      body.classList.remove('overflow-hidden', 'position-relative');
    } else {
      console.log('yo')
      body.classList.add('overflow-hidden', 'position-relative');
      const contentOverlay = document.createElement('div');
      contentOverlay.classList.add('content-overlay');
      body.appendChild(contentOverlay);
      this.navbarCollapseTarget.classList.add('active');
    }
  }
}
