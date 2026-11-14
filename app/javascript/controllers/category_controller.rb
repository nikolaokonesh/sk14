import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, csrf: String }

  pick(event) {
    const id = event.params.id

    fetch(this.urlValue, {
      method: "PATCH",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfValue,
        "X-Requested-With": "XMLHttpRequest"
      },
      body: JSON.stringify({ post: { category_id: id } })
    }).then((response) => {
      if (!response.ok) alert("Не удалось обновить категорию")
    })
  }
}