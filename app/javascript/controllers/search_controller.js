import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["form", "input", "tag"]

  connect() {
    this.lastSubmittedValue = this.inputTarget?.value?.trim() || ""
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  update() {
    const nextValue = this.inputTarget.value.trim()
    if (nextValue === this.lastSubmittedValue) return
    // Сбрасываем таймер при каждом нажатии клавиши
    clearTimeout(this.timeout)

    // Устанавливаем новый таймер
    this.timeout = setTimeout(() => {
      this.lastSubmittedValue = nextValue
      this.formTarget.requestSubmit()
    }, 300)
  }

  set_query(event) {
    event.preventDefault()

    const btn = event.currentTarget
    const value = btn.dataset.searchValue || ""
    if (value === this.lastSubmittedValue) return

    this.inputTarget.value = value
    this.tagTargets.forEach(tag => {
      tag.classList.remove("btn-primary", "text-white")
      tag.classList.add("btn-ghost", "bg-base-200")
    })
    btn.classList.add("btn-primary", "text-white")
    btn.classList.remove("btn-ghost", "bg-base-200")
    
    this.lastSubmittedValue = value
    this.formTarget.requestSubmit()
  }

  reset() {
    if (this.lastSubmittedValue === "") return

    this.inputTarget.value = "" // Очищаем поле
    this.lastSubmittedValue = ""
    this.formTarget.requestSubmit() // Отправляем пустой запрос для сброса фильтра
  }
}
