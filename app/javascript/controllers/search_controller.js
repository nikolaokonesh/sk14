import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["form", "input", "tag"]

  update() {
    // Сбрасываем таймер при каждом нажатии клавиши
    clearTimeout(this.timeout)

    // Устанавливаем новый таймер
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  set_query(event) {
    const btn = event.currentTarget
    const value = btn.dataset.searchValue
    this.inputTarget.value = value
    this.tagTargets.forEach(tag => {
      tag.classList.remove("btn-primary", "text-white")
      tag.classList.add("btn-ghost", "bg-base-200")
    })
    btn.classList.add("btn-primary", "text-white")
    btn.classList.remove("btn-ghost", "bg-base-200")
    this.formTarget.requestSubmit()
  }

  reset() {
    this.inputTarget.value = "" // Очищаем поле
    this.formTarget.requestSubmit() // Отправляем пустой запрос для сброса фильтра
  }
}
