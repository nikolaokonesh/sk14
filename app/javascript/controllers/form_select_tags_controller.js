// Connects to data-controller="form-select-tags"
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  // Находим все чекбоксы внутри контроллера
  static targets = ["checkbox"]

  toggle(event) {
    const clickedLabel = event.currentTarget
    const checkbox = clickedLabel.querySelector('input[type="checkbox"]')
    const name = checkbox.getAttribute('name')

    // Ждем микро-тик, чтобы браузер обновил состояние .checked
    setTimeout(() => {
      // Логика взаимоисключения для Срочно и Важно
      if (checkbox.checked) {
        if (name.includes('[urgent]')) this.uncheck('important')
        if (name.includes('[important]')) this.uncheck('urgent')
      }
      
      this.refreshVisuals()
    }, 10)
  }

  // Снимает галочку с указанного поля
  uncheck(fieldName) {
    this.checkboxTargets.forEach(cb => {
      if (cb.getAttribute('name').includes(`[${fieldName}]`)) {
        cb.checked = false
      }
    })
  }

  // Обновляет цвета всех бейджей на основе состояния чекбоксов
  refreshVisuals() {
    this.checkboxTargets.forEach(cb => {
      const badge = cb.closest('label').querySelector('.badge')
      const activeClassBg = badge.dataset.activeColorBg
      const activeClassText = badge.dataset.activeColorText
      
      if (cb.checked) {
        badge.classList.remove('badge-ghost', 'opacity-50')
        badge.classList.add(activeClassBg, activeClassText, 'border-transparent', 'scale-105')
      } else {
        badge.classList.add('badge-ghost', 'opacity-50')
        badge.classList.remove(activeClassBg, activeClassText, 'border-transparent', 'scale-105')
      }
    })
  }
}
