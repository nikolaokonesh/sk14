import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["form", "input"]

  update() {
    // Сбрасываем таймер при каждом нажатии клавиши
    clearTimeout(this.timeout)

    // Устанавливаем новый таймер
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  reset() {
    this.inputTarget.value = "" // Очищаем поле
    this.formTarget.requestSubmit() // Отправляем пустой запрос для сброса фильтра
  }
}
