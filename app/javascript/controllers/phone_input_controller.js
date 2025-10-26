import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="phone-input"
export default class extends Controller {
  static targets = ["input"]
  
  connect() {
    this.formatOnInput()
  }
  
  formatOnInput() {
    if (!this.hasInputTarget) return
    
    this.inputTarget.addEventListener('input', (e) => {
      const cursorPosition = e.target.selectionStart
      const oldLength = e.target.value.length
      
      // Remove all non-digits
      let value = e.target.value.replace(/\D/g, '')
      
      // Auto-add +1 prefix for US numbers
      if (value.length > 0 && !value.startsWith('1')) {
        value = '1' + value
      }
      
      // Limit to 11 digits (1 + 10)
      value = value.slice(0, 11)
      
      // Format as +1 (XXX) XXX-XXXX or +1XXXXXXXXXX
      if (value.length >= 1) {
        e.target.value = '+' + value
      }
      
      // Restore cursor position (accounting for formatting changes)
      const newLength = e.target.value.length
      const diff = newLength - oldLength
      e.target.setSelectionRange(cursorPosition + diff, cursorPosition + diff)
    })
    
    // Validate on blur
    this.inputTarget.addEventListener('blur', () => {
      this.validate()
    })
  }
  
  validate() {
    if (!this.hasInputTarget) return false
    
    const value = this.inputTarget.value
    const isValid = /^\+1\d{10}$/.test(value)
    
    if (value && !isValid) {
      this.inputTarget.classList.add('border-destructive')
      this.inputTarget.classList.remove('border-input')
      
      // Show error message if there's a sibling error element
      const errorElement = this.inputTarget.parentElement.querySelector('.error-message')
      if (errorElement) {
        errorElement.textContent = 'Please enter a valid US phone number (+1 and 10 digits)'
        errorElement.classList.remove('hidden')
      }
      
      return false
    } else {
      this.inputTarget.classList.remove('border-destructive')
      this.inputTarget.classList.add('border-input')
      
      // Hide error message
      const errorElement = this.inputTarget.parentElement.querySelector('.error-message')
      if (errorElement) {
        errorElement.classList.add('hidden')
      }
      
      return true
    }
  }
  
  // Action to validate before form submit
  validateBeforeSubmit(event) {
    if (!this.validate()) {
      event.preventDefault()
      event.stopPropagation()
      
      // Focus the invalid input
      this.inputTarget.focus()
    }
  }
}

