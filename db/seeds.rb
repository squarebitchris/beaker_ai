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
    "first_message" => "Hi! I'm calling from {{business_name}} about your HVAC needs. Do you have a few minutes to talk?",
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

# Seed Knowledge Base entries
puts "Seeding knowledge base entries..."

# HVAC Knowledge Base
hvac_kb = [
  { category: 'services', content: 'HVAC emergency services are available 24/7 for urgent heating/cooling failures', priority: 10 },
  { category: 'services', content: 'Common HVAC issues include refrigerant leaks, thermostat problems, and filter clogs', priority: 8 },
  { category: 'pricing', content: 'Annual maintenance visits cost $80-150 and prevent 95% of emergency breakdowns', priority: 9 },
  { category: 'pricing', content: 'HVAC system replacement costs $3,500-7,500 depending on home size', priority: 7 },
  { category: 'services', content: 'Emergency service calls typically arrive within 2 hours', priority: 9 },
  { category: 'services', content: 'We provide free estimates for all HVAC installations and major repairs', priority: 8 },
  { category: 'general', content: 'Regular filter changes every 1-3 months extend system life by years', priority: 6 }
]

hvac_kb.each do |entry|
  KnowledgeBase.find_or_create_by!(
    industry: 'hvac',
    category: entry[:category],
    content: entry[:content]
  ) do |kb|
    kb.priority = entry[:priority]
    kb.active = true
  end
end

# Gym Knowledge Base
gym_kb = [
  { category: 'services', content: 'Most gym memberships include a free fitness assessment and training session', priority: 9 },
  { category: 'services', content: 'Group classes are free with membership at most facilities', priority: 8 },
  { category: 'pricing', content: 'Personal training packages start at $50/session with discounts for bulk purchases', priority: 8 },
  { category: 'hours', content: 'Gym hours vary: 24-hour access, 5am-midnight, or standard 6am-10pm', priority: 7 },
  { category: 'services', content: 'First-time visitors can try a free 1-day pass to tour facilities', priority: 10 },
  { category: 'services', content: 'We offer specialized programs for weight loss, muscle gain, and athletic performance', priority: 7 },
  { category: 'general', content: 'Month-to-month memberships available with no long-term contracts required', priority: 6 }
]

gym_kb.each do |entry|
  KnowledgeBase.find_or_create_by!(
    industry: 'gym',
    category: entry[:category],
    content: entry[:content]
  ) do |kb|
    kb.priority = entry[:priority]
    kb.active = true
  end
end

# Dental Knowledge Base
dental_kb = [
  { category: 'services', content: 'Dental cleanings are recommended every 6 months for optimal oral health', priority: 9 },
  { category: 'pricing', content: 'Most insurance plans cover 2 cleanings and 1 exam per year at 100%', priority: 10 },
  { category: 'services', content: 'Emergency dental appointments for severe pain available same-day', priority: 10 },
  { category: 'pricing', content: 'Cosmetic procedures like whitening are usually not covered by insurance', priority: 6 },
  { category: 'services', content: 'New patient exams include full X-rays and cleaning (2-hour appointment)', priority: 8 },
  { category: 'services', content: 'We offer sedation dentistry for patients with dental anxiety', priority: 7 },
  { category: 'general', content: 'Flexible payment plans available for major dental work', priority: 7 }
]

dental_kb.each do |entry|
  KnowledgeBase.find_or_create_by!(
    industry: 'dental',
    category: entry[:category],
    content: entry[:content]
  ) do |kb|
    kb.priority = entry[:priority]
    kb.active = true
  end
end

puts "Knowledge base seeding complete!"
puts "  - HVAC: #{KnowledgeBase.for_industry('hvac').count} entries"
puts "  - Gym: #{KnowledgeBase.for_industry('gym').count} entries"
puts "  - Dental: #{KnowledgeBase.for_industry('dental').count} entries"
