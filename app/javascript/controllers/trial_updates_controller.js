import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { trialId: String }

  connect() {
    if (!window.ActionCable) {
      console.error("ActionCable is not available")
      return
    }

    // Create consumer connection
    this.cable = ActionCable.createConsumer()

    // Subscribe to trial updates channel
    this.subscription = this.cable.subscriptions.create(
      {
        channel: "TrialChannel",
        id: this.trialIdValue
      },
      {
        received(data) {
          // Turbo will handle the broadcast automatically
          console.log("Received trial update:", data)
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

