import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static values = {
    storageKey: { type: String, default: "beaker-theme" }
  }

  connect() {
    // Apply saved theme on page load
    this.applyTheme(this.getStoredTheme())
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    
    this.applyTheme(newTheme)
    this.storeTheme(newTheme)
    
    // Emit custom event for analytics or other listeners
    this.dispatch("changed", { detail: { theme: newTheme } })
  }

  // Private methods

  getCurrentTheme() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  getStoredTheme() {
    try {
      return localStorage.getItem(this.storageKeyValue) || this.getSystemTheme()
    } catch {
      return this.getSystemTheme()
    }
  }

  getSystemTheme() {
    if (window.matchMedia && window.matchMedia("(prefers-color-scheme: dark)").matches) {
      return "dark"
    }
    return "light"
  }

  storeTheme(theme) {
    try {
      localStorage.setItem(this.storageKeyValue, theme)
    } catch (error) {
      console.warn("Failed to save theme preference:", error)
    }
  }

  applyTheme(theme) {
    if (theme === "dark") {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }
}

