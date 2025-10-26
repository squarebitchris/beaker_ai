import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["submit"]

  connect() {
    this.form = this.element
  }

  submit(event) {
    // Disable submit button to prevent double submission
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.textContent = "Creating..."
    }
    
    // Add loading state to form - but don't prevent form submission
    // The form will submit normally, and if there are validation errors,
    // the page will reload and the disconnect method will clean up
    this.form.classList.add("opacity-75")
  }

  // Re-enable form if there are validation errors
  disconnect() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.textContent = "Create My Assistant"
    }
    this.form.classList.remove("opacity-75", "pointer-events-none")
  }
}
