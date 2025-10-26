class TrialChannel < ApplicationCable::Channel
  def subscribed
    trial = Trial.find_by(id: params[:id])

    # Authorization: Only trial owner can subscribe
    if trial && current_user && trial.user_id == current_user.id
      stream_from "trial:#{trial.id}"
    else
      reject
    end
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
  end
end
