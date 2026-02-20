import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auth-visibility"
export default class extends Controller {
  static values = { authorId: String }
  static targets = ["controls"]

  connect() {
    const currentUserId = document.body.dataset.currentUserId
    if (currentUserId && currentUserId === this.authorIdValue) {
      if (this.hasControlsTarget) {
        this.controlsTarget.classList.remove("hidden")
      }
    }
  }
}
