import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="auth-visibility"
export default class extends Controller {
  static values = { authorId: String }
  static targets = ["controls"]

  connect() {
    const currentUserId = document.body.dataset.currentUserId
    const isAdmin = document.body.dataset.currentUserAdmin === "true"
    const isModerator = document.body.dataset.currentUserModerator === "true"

    if ((currentUserId && currentUserId === this.authorIdValue) || isAdmin || isModerator) {
      if (this.hasControlsTarget) {
        this.controlsTarget.classList.remove("hidden")
      }
    }
  }
}
