# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create HVAC lead intake scenario template
ScenarioTemplate.find_or_create_by!(key: "hvac_lead_intake", active: true) do |template|
  template.version = 1
  template.prompt_pack = {
    "system" => "You are a professional HVAC assistant specializing in lead intake and qualification. Your goal is to gather contact information and understand the customer's HVAC needs. Be friendly, professional, and efficient. Keep calls under 2 minutes.",
    "first_message" => "Hi! I'm calling from [COMPANY_NAME] about your HVAC needs. Do you have a few minutes to talk?",
    "tools" => [
      {
        "type" => "function",
        "function" => {
          "name" => "capture_lead",
          "description" => "Capture lead information when customer provides it",
          "parameters" => {
            "type" => "object",
            "properties" => {
              "name" => {
                "type" => "string",
                "description" => "Customer's full name"
              },
              "phone" => {
                "type" => "string",
                "description" => "Customer's phone number"
              },
              "email" => {
                "type" => "string",
                "description" => "Customer's email address"
              },
              "address" => {
                "type" => "string",
                "description" => "Customer's address"
              },
              "issue_description" => {
                "type" => "string",
                "description" => "Description of HVAC issue or need"
              },
              "urgency" => {
                "type" => "string",
                "enum" => [ "urgent", "moderate", "low" ],
                "description" => "How urgent is the HVAC need"
              },
              "preferred_contact_time" => {
                "type" => "string",
                "description" => "When customer prefers to be contacted"
              }
            },
            "required" => [ "name", "phone", "issue_description" ]
          }
        }
      }
    ]
  }
  template.notes = "HVAC lead intake scenario template for trial users"
end
