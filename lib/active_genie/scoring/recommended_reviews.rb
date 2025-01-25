# frozen_string_literal: true

require_relative '../clients/router.rb'

module ActiveGenie::Scoring
  # The RecommendedReviews class intelligently suggests appropriate reviewer roles
  # for evaluating text content based on specific criteria. It uses AI to analyze
  # the content and criteria to identify the most suitable subject matter experts.
  #
  # The class ensures a balanced and comprehensive review process by recommending
  # three distinct reviewer roles with complementary expertise and perspectives.
  #
  # @example Getting recommended reviewers for technical content
  #   RecommendedReviews.call("Technical documentation about API design", 
  #                           "Evaluate technical accuracy and clarity")
  #   # => { reviewer1: "API Architect", reviewer2: "Technical Writer", 
  #   #      reviewer3: "Developer Advocate", reasoning: "..." }
  #
  class RecommendedReviews
    def self.call(text, criteria, options: {})
      new(text, criteria, options:).call
    end

    # Initializes a new reviewer recommendation instance
    #
    # @param text [String] The text content to analyze for reviewer recommendations
    # @param criteria [String] The evaluation criteria that will guide reviewer selection
    # @param options [Hash] Additional configuration options that modify the recommendation process
    # @option options [Boolean] :prefer_technical Whether to favor technical expertise
    # @option options [Boolean] :prefer_domain Whether to favor domain expertise
    def initialize(text, criteria, options: {})
      @text = text
      @criteria = criteria
      @options = options
    end

    def call
      messages = [
        {  role: 'system', content: PROMPT },
        {  role: 'user', content: "Scoring criteria: #{@criteria}" },
        {  role: 'user', content: "Text to score: #{@text}" },
      ]

      function = {
        name: 'identify_reviewers',
        description: 'Discover reviewers based on the text and given criteria.',
        schema: {
          type: "object",
          properties: {
            reasoning: { type: 'string' },
            reviewer1: { type: 'string' },
            reviewer2: { type: 'string' },
            reviewer3: { type: 'string' },
          }
        }
      }

      ::ActiveGenie::Clients::Router.function_calling(messages, function, options:)
    end

    private

    PROMPT = <<~PROMPT
    Identify the top 3 suitable reviewer titles or roles based on the provided text and criteria. Selected reviewers must possess subject matter expertise, offer valuable insights, and ensure diverse yet aligned perspectives on the content.

    # Instructions
    1. **Analyze the Text and Criteria**: Examine the content and criteria to identify relevant reviewer titles or roles.
    2. **Determine Subject Matter Expertise**: Select reviewers with substantial knowledge or experience in the subject area.
    3. **Evaluate Insight Contribution**: Prioritize titles or roles capable of providing meaningful and actionable feedback on the content.
    4. **Incorporate Perspective Diversity**: Ensure the selection includes reviewers with varied but complementary viewpoints while maintaining alignment with the criteria.

    # Constraints
    - Selected reviewers must align with the content’s subject matter and criteria.
    - Include reasoning for how each choice supports a thorough and insightful review.
    - Avoid redundant or overly similar titles/roles to maintain diversity.
    PROMPT
  end
end
