import { Controller } from "@hotwired/stimulus"
import { post } from "@rails/request.js"

export default class extends Controller {
  static targets = ["picker", "pickerhide"]

  // Показать/Скрыть панель выбора эмодзи
  togglePicker(event) {
    event.stopPropagation()

    document.querySelectorAll('[data-reactions-target="picker"]').forEach((el) => {
      if (el !== this.pickerTarget) {
        el.classList.add("hidden")
      }
    })

    this.pickerTarget.classList.toggle("hidden")

    if (!this.pickerTarget.classList.contains("hidden")) {
      document.addEventListener("click", () => this.hide(), { once: true })
    }
  }

  hide() {
    this.pickerTarget.classList.add("hidden")
  }

  async select(event) {
    const { content, entryId } = event.params

    await post(`/entries/${entryId}/reactions/toggle`, {
      body: JSON.stringify({ content }),
      contentType: "application/json",
      responseKind: "json"
    })

    this.hide()
  }
}
