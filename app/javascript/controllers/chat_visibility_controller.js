import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chat-visibility"
export default class extends Controller {
  static values = { authorId: String }
  static targets = ["chat", "avatar", "username", "bgcolor"]

  connect() {
    const currentUserId = document.body.dataset.currentUserId
    const authorId = this.element.dataset.authVisibilityAuthorIdValue
    if (currentUserId && currentUserId === authorId) {
      if (this.hasChatTarget) {
        this.chatTarget.classList.add("chat-end")
        this.chatTarget.classList.remove("chat-start")
      }
      if (this.hasAvatarTarget) {
        this.avatarTarget.classList.add("hidden")
      }
      if (this.hasUsernameTarget) {
        this.usernameTarget.classList.add("hidden")
      }
      if (this.hasBgcolorTarget) {
        this.bgcolorTarget.classList.add("dark:bg-violet-900", "bg-violet-300")
      }
    }
  }
}
