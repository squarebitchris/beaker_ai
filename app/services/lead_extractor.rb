# frozen_string_literal: true

# Extract lead data from Vapi function calls
class LeadExtractor
  def self.from_function_calls(function_calls)
    return {} if function_calls.blank?

    # Handle array or single function call
    calls_array = Array.wrap(function_calls).map(&:with_indifferent_access)

    # Find capture_lead function
    capture_lead = calls_array.find { |fc| fc[:name] == "capture_lead" }
    return {} unless capture_lead

    # Extract parameters
    params = capture_lead[:parameters] || {}
    params = params.with_indifferent_access

    {
      name: params[:name],
      phone: params[:phone],
      email: params[:email],
      intent: params[:intent],
      notes: params[:notes]
    }.compact.reject { |_k, v| v.blank? }
  end
end
