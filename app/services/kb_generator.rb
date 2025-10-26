class KbGenerator
  class << self
    # Fetch KB entries for a given industry
    # Returns array of content strings
    def for_industry(industry)
      KnowledgeBase
        .for_assistant(industry)
        .pluck(:content)
    end

    # Format KB entries as prompt context
    # Returns formatted string ready to inject into system prompt
    def to_prompt_context(industry)
      facts = for_industry(industry)
      return "" if facts.empty?

      "\n\n## Business Knowledge\n" + facts.map { |f| "- #{f}" }.join("\n")
    end

    # Get KB entries grouped by category
    # Returns hash of { category => [content] }
    def by_category(industry)
      KnowledgeBase
        .for_assistant(industry)
        .group_by(&:category)
        .transform_values { |entries| entries.map(&:content) }
    end
  end
end
