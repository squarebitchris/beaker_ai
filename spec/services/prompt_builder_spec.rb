require 'rails_helper'

RSpec.describe PromptBuilder do
  let(:template_prompt_pack) do
    {
      "system" => "You are a {{industry}} assistant for {{business_name}}.",
      "first_message" => "Hi! I'm calling from {{business_name}}. How can I help?",
      "tools" => [
        {
          "type" => "function",
          "function" => {
            "name" => "capture_lead",
            "description" => "Capture lead info"
          }
        }
      ]
    }
  end

  let(:persona) do
    {
      "business_name" => "AC Pro HVAC",
      "industry" => "HVAC"
    }
  end

  describe '.call' do
    it 'replaces placeholders in system prompt' do
      result = described_class.call(template: template_prompt_pack, persona: persona)

      expect(result[:system]).to eq("You are a HVAC assistant for AC Pro HVAC.")
      expect(result[:system]).not_to include("{{")
    end

    it 'replaces placeholders in first_message' do
      result = described_class.call(template: template_prompt_pack, persona: persona)

      expect(result[:first_message]).to eq("Hi! I'm calling from AC Pro HVAC. How can I help?")
      expect(result[:first_message]).not_to include("{{")
    end

    it 'preserves tools array unchanged' do
      result = described_class.call(template: template_prompt_pack, persona: persona)

      expect(result[:tools]).to eq(template_prompt_pack["tools"])
    end

    it 'returns hash with symbol keys' do
      result = described_class.call(template: template_prompt_pack, persona: persona)

      expect(result.keys).to match_array([ :system, :first_message, :tools ])
    end
  end

  describe 'merge precedence' do
    it 'persona overrides template values' do
      template_with_default = template_prompt_pack.merge("custom_field" => "template_value")
      persona_with_override = persona.merge("custom_field" => "persona_value")

      result = described_class.call(
        template: template_with_default,
        persona: persona_with_override
      )

      # Persona value wins in deep merge
      expect(result[:system]).to include("HVAC")
    end

    it 'kb overrides template but persona overrides kb' do
      kb = { "business_name" => "KB Business" }

      result = described_class.call(
        template: template_prompt_pack,
        persona: persona,
        kb: kb
      )

      # Persona wins over KB
      expect(result[:first_message]).to include("AC Pro HVAC")
    end
  end

  describe 'missing placeholders' do
    it 'leaves unreplaced placeholders in text' do
      incomplete_persona = { "business_name" => "AC Pro" }
      # Missing "industry"

      result = described_class.call(
        template: template_prompt_pack,
        persona: incomplete_persona
      )

      expect(result[:system]).to include("{{industry}}")
      expect(result[:system]).to include("AC Pro")
    end

    it 'logs warning for missing placeholders' do
      incomplete_persona = { "business_name" => "AC Pro" }

      expect(Rails.logger).to receive(:warn).with(
        /Missing placeholder values: industry/
      )

      described_class.call(
        template: template_prompt_pack,
        persona: incomplete_persona
      )
    end

    it 'does not fail when placeholders are missing' do
      expect {
        described_class.call(template: template_prompt_pack, persona: {})
      }.not_to raise_error
    end
  end

  describe 'immutability' do
    it 'does not mutate template input' do
      original_template = template_prompt_pack.dup

      described_class.call(template: template_prompt_pack, persona: persona)

      expect(template_prompt_pack).to eq(original_template)
    end

    it 'does not mutate persona input' do
      original_persona = persona.dup

      described_class.call(template: template_prompt_pack, persona: persona)

      expect(persona).to eq(original_persona)
    end
  end

  describe 'edge cases' do
    it 'handles nil text fields gracefully' do
      template_with_nil = template_prompt_pack.merge("system" => nil)

      result = described_class.call(template: template_with_nil, persona: persona)

      expect(result[:system]).to be_nil
    end

    it 'handles empty persona' do
      result = described_class.call(template: template_prompt_pack, persona: {})

      expect(result[:system]).to include("{{business_name}}")
      expect(result[:tools]).to be_an(Array)
    end

    it 'returns empty array when tools is missing' do
      template_without_tools = {
        "system" => "Test",
        "first_message" => "Hello"
      }

      result = described_class.call(template: template_without_tools, persona: persona)

      expect(result[:tools]).to eq([])
    end

    it 'handles multiple occurrences of same placeholder' do
      template = {
        "system" => "{{business_name}} is great. Call {{business_name}} today!",
        "first_message" => "Hi from {{business_name}}"
      }

      result = described_class.call(template: template, persona: persona)

      expect(result[:system]).to eq("AC Pro HVAC is great. Call AC Pro HVAC today!")
      expect(result[:first_message]).to eq("Hi from AC Pro HVAC")
    end
  end

  describe 'integration with ScenarioTemplate' do
    let(:template) { create(:scenario_template, :hvac_lead_intake) }
    let(:trial) { create(:trial, business_name: "Smith HVAC", industry: "hvac") }

    it 'works with real ScenarioTemplate prompt_pack' do
      persona_hash = {
        "business_name" => trial.business_name,
        "industry" => trial.industry
      }

      result = described_class.call(
        template: template.prompt_pack,
        persona: persona_hash
      )

      expect(result[:first_message]).not_to include("[COMPANY_NAME]")
      expect(result[:tools]).to be_an(Array)
    end
  end
end
