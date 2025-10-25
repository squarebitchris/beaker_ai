class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Note: authenticate_user! is NOT enforced globally
  # Trial pages remain public; dashboard/business pages require auth
  helper_method :current_user
end
