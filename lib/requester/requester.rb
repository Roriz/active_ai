require_relative './openai'

module ActiveGenie
  class Requester    
    class << self
      def function_calling(messages, function, options = {})
        app_config = ActiveGenie.config_by_model(options[:model])
        
        provider = options[:provider] || app_config[:provider]
        provider_sdk = PROVIDER_TO_SDK[provider&.to_sym&.downcase]
        raise "Provider #{provider} not supported" unless provider_sdk

        response = provider_sdk.function_calling(messages, function, options)

        clear_invalid_values(response)
      end

      private

      PROVIDER_TO_SDK = {
        openai: Openai,
      }

      INVALID_VALUES = [
        'not sure',
        'not clear',
        'not specified',
        'none',
        'null',
        'undefined',
      ].freeze

      def clear_invalid_values(data)
        data.reduce({}) do |acc, (field, value)|
          acc[field] = value unless INVALID_VALUES.include?(value)
          acc
        end
      end
    end
  end
end
