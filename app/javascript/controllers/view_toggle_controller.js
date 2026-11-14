import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["categories", "linear", "tab"]

  connect() {
    const savedMode = localStorage.getItem("viewMode") || "categories"
    this.show(savedMode)
  }

  switch(event) {
    const mode = event.currentTarget.dataset.mode
    this.show(mode)
    localStorage.setItem("viewMode", mode)
  }

  show(mode) {
    this.categoriesTarget.hidden = mode !== "categories"
    this.linearTarget.hidden = mode !== "linear"

    this.tabTargets.forEach(tab => {
      const active = tab.dataset.mode === mode
      tab.classList.toggle("bg-base-100", active)
      tab.classList.toggle("shadow", active)
      tab.classList.toggle("text-primary", active)
      tab.classList.toggle("opacity-60", !active)
    })
  }
}