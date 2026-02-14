import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="close-modal"
export default class extends Controller {
  close() {
    this.element.classList.remove("modal-open")
  }
}
