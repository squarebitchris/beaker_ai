FactoryBot.define do
  factory :scenario_template do
    key { "hvac_lead_intake" }
    version { 1 }
    active { true }
    prompt_pack do
      {
        "system" => "You are a helpful HVAC assistant for lead intake.",
        "first_message" => "Hi! I'm calling about your HVAC needs.",
        "tools" => []
      }
    end
    notes { "HVAC lead intake scenario template" }

    trait :inactive do
      active { false }
    end

    trait :hvac_lead_intake do
      key { "hvac_lead_intake" }
      version { 1 }
      active { true }
      prompt_pack do
        {
          "system" => "You are a professional HVAC assistant specializing in lead intake and qualification.",
          "first_message" => "Hi! I'm calling from [COMPANY_NAME] about your HVAC needs. Do you have a few minutes to talk?",
          "tools" => [
            {
              "type" => "function",
              "function" => {
                "name" => "capture_lead",
                "description" => "Capture lead information",
                "parameters" => {
                  "type" => "object",
                  "properties" => {
                    "name" => { "type" => "string" },
                    "phone" => { "type" => "string" },
                    "email" => { "type" => "string" },
                    "address" => { "type" => "string" },
                    "issue_description" => { "type" => "string" },
                    "urgency" => { "type" => "string", "enum" => [ "urgent", "moderate", "low" ] }
                  }
                }
              }
            }
          ]
        }
      end
    end
  end
end
