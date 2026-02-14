// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

import "lexxy"
import "@rails/actiontext"

const useViewTransition = (event) => {
  if (document.startViewTransition && !event.detail.renderWrapper) {
    const originalRender = event.detail.render;
    event.detail.render = (currentElement, newElement) => {
      document.startViewTransition(() => {
        originalRender(currentElement, newElement)
      })
    }
    event.detail.renderWrapper = true;
  }
}

document.addEventListener("turbo:before-frame-render", useViewTransition)
document.addEventListener("turbo:before-stream-render", useViewTransition)
document.addEventListener("turbo:before-cache", () => {
  const flash = document.getElementById("flash")
  
  if (flash) {
    flash.innerHTML = ""
  }
})