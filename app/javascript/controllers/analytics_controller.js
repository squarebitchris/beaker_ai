import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { 
    event: String,
    callId: String,
    trialId: String
  }

  trackUpgradeClick(event) {
    // Log to console for now (Phase 3 will send to analytics service)
    console.log("Upgrade CTA clicked", {
      event: this.eventValue,
      callId: this.callIdValue,
      trialId: this.trialIdValue,
      timestamp: new Date().toISOString()
    })
    
    // Store in localStorage for Phase 3 conversion attribution
    const clicks = JSON.parse(localStorage.getItem('upgrade_clicks') || '[]')
    clicks.push({
      callId: this.callIdValue,
      trialId: this.trialIdValue,
      timestamp: new Date().toISOString()
    })
    localStorage.setItem('upgrade_clicks', JSON.stringify(clicks))
  }
}

