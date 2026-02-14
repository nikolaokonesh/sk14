import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="reset-form" это есть в Comments::Form
export default class extends Controller {
  static targets = ["input"]

  prepareSubmission(event) {
    const editor = this.element.querySelector('.lexxy-editor__content')
    editor.focus()
  }

  reset(event) {
    const editor = this.element.querySelector('.lexxy-editor__content')
    if (event.detail.success) {
      editor.value = ""
      this.element.reset()
      editor.focus()
    }
  }
}
