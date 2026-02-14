import { Application } from "@hotwired/stimulus"
import AutoSubmit from "@stimulus-components/auto-submit"
import Notification from "@stimulus-components/notification"

const application = Application.start()
application.register('auto-submit', AutoSubmit)
application.register('notification', Notification)

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }