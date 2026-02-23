import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autoscroll" используется в блоке комментария
export default class extends Controller {
  static targets = ["badge"]

  connect() {
    this.notificationsActive = false

    // 1. Находим контейнер (это сам элемент контроллера)
    this.scrollContainer = this.element

    this.observer = new MutationObserver((mutations) => {
      this.handleMutation(mutations)
    })
    this.observer.observe(this.scrollContainer, { childList: true, subtree: true })

    this.scrollContainer.addEventListener("scroll", () => this.handleScroll())
    setTimeout(() => {
      this.notificationsActive = true
    }, 500)

    if (window.visualViewport) {
      window.visualViewport.addEventListener("resize", () => {
        if (this.isNearBottom()) {
          this.scrollToBottom()
        }
      })
    }
  }

  disable_click() {
    this.element.style.pointerEvents = "none"
    this.element.classList.add("opacity-50", "cursor-wait")
  }

  disconnect() {
    this.observer.disconnect()
  }

  handleMutation(mutations) {
    if (!this.notificationsActive) return

    let isNewMessage = false
    let isAuthor = false
    let isLastElement = false

    const currentUserId = document.body.dataset.currentUserId

    for (const mutation of mutations) {
      if (mutation.target.closest?.('turbo-frame[id^="load_"]')) continue

      if (mutation.addedNodes.length === 0) continue
      
      let hasPaginationInNotes = false

      mutation.addedNodes.forEach(node => {
        if (node.nodeType !== 1) return
        
        if (node.tagName === "TURBO-FRAME" && node.id?.startWith("load_")) {
          hasPaginationInNotes = true
          return
        }
        const entryNode = node.classList.contains("entry-card") ? node : node.querySelector(".entry-card")

        if (entryNode) {
          if (entryNode.closest('turbo-frame[id^="load_"]')) return
          const allEntries = Array.from(this.scrollContainer.querySelectorAll(".entry-card"))
          const lastInDom = allEntries[allEntries.length - 1]
          if (entryNode === lastInDom || entryNode.contains(lastInDom)) {
            isLastElement = true
          }

          const isReplace = mutation.removedNodes.length > 0

          if (!isReplace) {
            isNewMessage = true
          }

          const authorId = node.dataset.authVisibilityAuthorIdValue ||
                           node.querySelector("[data-auth-visibility-author-id-value]")?.dataset.authVisibilityAuthorIdValue
          if (currentUserId && authorId === currentUserId) {
            isAuthor = true
          }
        }
      })
    }

    if (isNewMessage && isLastElement) {
      if (isAuthor || this.isNearBottom()) {
        this.scrollToBottom()
      } else if (isLastElement) {
        this.showBadge()
      }
    }
  }

  handleScroll() {
    if (this.isNearBottom()) {
      const goToLatest = this.element.querySelector("#go_to_latest")
      if (goToLatest) {
        goToLatest.classList.add("hidden")
      }
      this.hideBadge()
    }
  }

  isNearBottom() {
    const threshold = 250
    const position = this.scrollContainer.scrollTop + this.scrollContainer.clientHeight 
    const height = this.scrollContainer.scrollHeight
    return position >= (height - threshold)
  }

  showBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.remove("hidden")
      this.badgeTarget.classList.add("animate-bounce-short")
      setTimeout(() => {
        this.badgeTarget.classList.remove("animate-bounce-short")
      }, 3000)
    }
  }

  hideBadge() {
    if (this.hasBadgeTarget) {
      this.badgeTarget.classList.add("hidden")
    }
  }

  scrollToBottom() {
    this.scrollContainer.scrollTo({
      top: this.scrollContainer.scrollHeight,
      behavior: "smooth"
    })
    this.hideBadge()
  }
}
