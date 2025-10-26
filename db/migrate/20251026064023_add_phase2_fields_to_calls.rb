class AddPhase2FieldsToCalls < ActiveRecord::Migration[8.1]
  def change
    # Phase 2: Store captured lead data separately from extracted_lead
    # extracted_lead = raw extraction from LeadExtractor service
    # captured = processed/validated lead data for UI display
    add_column :calls, :captured, :jsonb, default: {}, null: false
    
    # Store which scenario was used (lead_intake, scheduling, info)
    add_column :calls, :scenario_slug, :string
    
    # Add index for querying by scenario
    add_index :calls, :scenario_slug
    
    # Add GIN index for JSONB queries on captured fields
    add_index :calls, :captured, using: :gin
  end
end
