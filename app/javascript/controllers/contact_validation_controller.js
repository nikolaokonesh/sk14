import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error", "errorText", "success", "successText", "submit"]
  
  connect() {
    this.debounceTimer = null
    this.validate()
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }
  }

  validate() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    const contact = this.inputTarget.value
    const isEmpty = contact.length === 0

    if (isEmpty) {
      this.hideAll()
      this.disableSubmit()
      return
    }

    // Проверка на недопустимые символы для телефона
    const isPhone = !contact.includes('@')
    if (isPhone && /[a-zA-Zа-яА-ЯёЁ]/.test(contact.replace(/[\+\-\(\)\s]/g, ''))) {
      this.showError("Только цифры для телефона")
      this.disableSubmit()
      return
    }

    this.showNeutral()
    this.disableSubmit()

    this.debounceTimer = setTimeout(() => {
      this.checkFormat(contact)
    }, 500)
  }

  checkFormat(contact) {
    const isEmail = contact.includes('@')
    
    if (isEmail) {
      // Валидация email
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      if (emailRegex.test(contact)) {
        this.showSuccess("Email верный ✓")
        this.enableSubmit()
      } else {
        this.showError("Неверный формат email")
        this.disableSubmit()
      }
    } else {
      // Валидация телефона
      const cleaned = contact.replace(/\D/g, "")
      const startsCorrectly = /^(7|8)/.test(cleaned)
      const correctLength = cleaned.length === 11

      if (startsCorrectly && correctLength) {
        this.showSuccess("Телефон верный ✓")
        this.enableSubmit()
      } else if (startsCorrectly && cleaned.length < 11) {
        this.showNeutral()
        this.disableSubmit()
      } else if (!startsCorrectly && cleaned.length > 0) {
        this.showError("Номер должен начинаться с 7 или 8")
        this.disableSubmit()
      } else {
        this.showNeutral()
        this.disableSubmit()
      }
    }
  }

  hideAll() {
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden")
    if (this.hasSuccessTarget) this.successTarget.classList.add("hidden")
    this.inputTarget.classList.remove("input-error", "input-success", "border-error", "border-success")
  }

  showNeutral() {
    this.hideAll()
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.classList.remove("hidden")
      if (this.hasErrorTextTarget) this.errorTextTarget.textContent = message
    }
    if (this.hasSuccessTarget) this.successTarget.classList.add("hidden")
    
    this.inputTarget.classList.remove("input-success", "border-success")
    this.inputTarget.classList.add("input-error", "border-error")
  }

  showSuccess(message) {
    if (this.hasSuccessTarget) {
      this.successTarget.classList.remove("hidden")
      if (this.hasSuccessTextTarget) this.successTextTarget.textContent = message
    }
    if (this.hasErrorTarget) this.errorTarget.classList.add("hidden")
    
    this.inputTarget.classList.remove("input-error", "border-error")
    this.inputTarget.classList.add("input-success", "border-success")
  }

  disableSubmit() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.classList.add("btn-disabled")
    }
  }

  enableSubmit() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.classList.remove("btn-disabled")
    }
  }
}