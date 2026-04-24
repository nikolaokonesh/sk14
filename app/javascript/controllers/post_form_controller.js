import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["afishaFields", "standardFields", "checkbox"]

  connect() {
    this.syncUI() 
  }

  toggle() {
    this.syncUI()
    // УБРАЛИ: this.resetStandardFields()
    // УБРАЛИ: this.resetAfishaFields()
    // Теперь данные остаются в инпутах, даже если они скрыты
  }

  syncUI() {
    const isAfisha = this.checkboxTarget.checked
    this.afishaFieldsTarget.classList.toggle("hidden", !isAfisha)
    this.standardFieldsTarget.classList.toggle("hidden", isAfisha)
  }
}
