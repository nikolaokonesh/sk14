import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reply"
export default class extends Controller {
  static targets = ["container", "author", "text", "input", "textarea"]

  connect() {
    this.close()
  }

  trigger(event) {
    const { id, author, text } = event.params
    const editor = this.element.querySelector('.lexxy-editor__content')

    this.inputTarget.value = id

    this.authorTarget.textContent = author
    this.textTarget.textContent = text

    this.containerTarget.classList.remove("hidden")
    this.containerTarget.classList.add("flex")

    editor.focus()
  }

  submitEnd(event) {
    if (event.detail.success) {
      const lastEntry = document.querySelector(".last-entry")

      if (lastEntry) {
        this.close()
      } else {
        this.goToLatest()
      }
    }
  }

  goToLatest(event) {
    const frame = document.getElementById("comments")
    if (frame) {
      const baseUrl = window.location.pathname.replace(/\/$/, "")
      frame.src = `${baseUrl}/comments`
    }
  }

  close(event) {
    if (event) event.preventDefault()

    this.containerTarget.classList.add("hidden")
    this.containerTarget.classList.remove("flex")
    this.inputTarget.value = ""

    if (this.hasAuthorTarget) this.authorTarget.textContent = ""
    if (this.hasTextTarget) this.textTarget.textContent = ""
  }
}
