import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("turbo:before-frame-render", this.preserve.bind(this))
    this.element.addEventListener("turbo:frame-render", this.restore.bind(this))
    
    const highlighted = this.element.querySelector('.js-highlighted-comment')
    
    if (highlighted) {
      highlighted.scrollIntoView({ block: 'center', behavior: "instant" })
      this.flash(highlighted)
    } else {
      // Если нет подсветки конкретного коммента — сразу идем в самый низ
      this.scrollToBottom()
    }
  }

  scrollToBottom() {
    // requestAnimationFrame гарантирует, что стили уже применились
    requestAnimationFrame(() => {
      this.element.scrollTop = this.element.scrollHeight
    })
  }

  flash(el) {
    el.classList.add("bg-primary/30", "transition-all", "duration-1000")
    setTimeout(() => {
      el.classList.remove("bg-primary/30")
    }, 3000)
  }

  preserve(event) {
    this.oldScrollHeight = this.element.scrollHeight
    this.oldScrollTop = this.element.scrollTop
  }

  restore(event) {
    const frame = event.target
    // Если это загрузка "предыдущих" (история вверх)
    if (frame.id.includes("prev")) {
      const heightDifference = this.element.scrollHeight - this.oldScrollHeight
      this.element.scrollTop = this.oldScrollTop + heightDifference
    }
  }
}