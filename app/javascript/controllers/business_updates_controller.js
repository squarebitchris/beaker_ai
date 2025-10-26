import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { businessId: String }

  connect() {
    if (!window.ActionCable) {
      console.error("ActionCable is not available")
      return
    }

    this.cable = ActionCable.createConsumer()
    this.subscription = this.cable.subscriptions.create(
      {
        channel: "BusinessChannel",
        id: this.businessIdValue
      },
      {
        received(data) {
          console.log("Received business update:", data)
        }
      }
    )
  }

  disconnect() {
    if (this.subscription) {
      this.cable.subscriptions.remove(this.subscription)
    }
  }
}

