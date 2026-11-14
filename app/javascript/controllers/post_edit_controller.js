import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  updateView(event) {
    // НЕ вызываем event.preventDefault() — форма сама отправит запрос на сервер
    const formData = new FormData(event.target)
    const updatedHtml = formData.get("post[content]")

    if (updatedHtml !== null && this.hasContentTarget) {
      this.contentTarget.innerHTML = updatedHtml
    }
  }
}
