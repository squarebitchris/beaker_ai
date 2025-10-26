// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import * as ActionCable from "@rails/actioncable"

// Initialize ActionCable
window.ActionCable = ActionCable

import "./controllers"
