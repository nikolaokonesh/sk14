import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toast"]
  static values = { url: String, title: String }

  connect() {
    this.element.addEventListener("click", this.share.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("click", this.share.bind(this))
  }

  share(event) {
    event.preventDefault()
    event.stopPropagation()

    const url = this.urlValue
    const title = this.titleValue

    // 1. Нативный Web Share (мобильные с HTTPS)
    if (navigator.share) {
      navigator.share({ title: title, url: url }).catch(() => {})
      return
    }

    // 2. Копирование в буфер обмена
    this.copyToClipboard(url)
  }

  copyToClipboard(url) {
    // Современный API
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(url)
        .then(() => this.showToast("Ссылка скопирована!"))
        .catch(() => this.fallbackCopy(url))
      return
    }

    // Fallback для старых браузеров и HTTP
    this.fallbackCopy(url)
  }

  fallbackCopy(url) {
    const textarea = document.createElement("textarea")
    textarea.value = url
    textarea.style.position = "fixed"
    textarea.style.opacity = "0"
    textarea.style.left = "-9999px"
    document.body.appendChild(textarea)
    textarea.select()

    try {
      document.execCommand("copy")
      this.showToast("Ссылка скопирована!")
    } catch (e) {
      this.showToast("Не удалось скопировать ссылку")
    }

    document.body.removeChild(textarea)
  }

  showToast(message) {
    if (!this.hasToastTarget) return

    const toast = this.toastTarget
    const messageEl = toast.querySelector("[data-share-message]")
    if (messageEl) messageEl.textContent = message

    // Показываем toast
    toast.classList.remove("hidden", "opacity-0", "translate-y-4")
    toast.classList.add("opacity-100", "translate-y-0")

    // Скрываем через 2 секунды
    if (this.hideTimeout) clearTimeout(this.hideTimeout)
    this.hideTimeout = setTimeout(() => {
      toast.classList.remove("opacity-100", "translate-y-0")
      toast.classList.add("opacity-0", "translate-y-4")
    }, 2000)
  }
}