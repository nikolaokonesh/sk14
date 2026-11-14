import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { frameId: String }

  connect() {
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll)
    
    // Проверяем сразу при подключении
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  handleScroll() {
    const frame = document.getElementById(this.frameIdValue)
    if (!frame) return

    const nextUrl = frame.dataset.nextUrl
    if (!nextUrl || this.element.dataset.isLoading === "true") return

    const scrollPosition = window.scrollY + window.innerHeight
    const documentHeight = document.documentElement.scrollHeight

    if (scrollPosition >= documentHeight - 200) {
      this.element.dataset.isLoading = "true"
      frame.setAttribute("src", nextUrl)
      
      setTimeout(() => {
        this.element.dataset.isLoading = "false"
      }, 1000)
    }
  }
}