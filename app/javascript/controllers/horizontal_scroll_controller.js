import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { nextUrl: String, frameId: String }

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    this.element.addEventListener("scroll", this.handleScroll)
    
    // Проверяем состояние тумана при инициализации
    this.updateFog()
  }

  disconnect() {
    this.element.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    // 1. Обновляем видимость тумана
    this.updateFog()

    // 2. Твоя существующая логика подгрузки
    if (!this.nextUrlValue || this.element.dataset.isLoading === "true") return

    const isNearRightEdge = this.element.scrollLeft + this.element.clientWidth >= this.element.scrollWidth - 50

    if (isNearRightEdge) {
      this.element.dataset.isLoading = "true"
      
      const frame = document.getElementById(this.frameIdValue)
      if (frame) {
        frame.setAttribute("src", this.nextUrlValue)
      }
    }
  }

  // 🆕 Управление туманом
  updateFog() {
    const scrollLeft = this.element.scrollLeft
    const scrollWidth = this.element.scrollWidth
    const clientWidth = this.element.clientWidth

    // Находим обертку и элементы тумана
    const wrapper = this.element.parentElement
    if (!wrapper) return

    const leftFog = wrapper.querySelector('.fade-left')
    const rightFog = wrapper.querySelector('.fade-right')

    // Левый туман: показываем, если проскроллили вправо больше чем на 10px
    if (scrollLeft > 10) {
      leftFog?.classList.remove('opacity-0')
      leftFog?.classList.add('opacity-100')
    } else {
      leftFog?.classList.add('opacity-0')
      leftFog?.classList.remove('opacity-100')
    }

    // Правый туман: скрываем, если доскроллили до самого конца (с запасом 10px)
    if (scrollLeft + clientWidth >= scrollWidth - 10) {
      rightFog?.classList.add('opacity-0')
      rightFog?.classList.remove('opacity-100')
    } else {
      rightFog?.classList.remove('opacity-0')
      rightFog?.classList.add('opacity-100')
    }
  }
}