require 'fluent/plugin/filter'
require 'llmalfr'

module Fluent::Plugin
  class LlmGenerateFilter < Filter
    Fluent::Plugin.register_filter('llm_generate', self)

    # Configuration parameters
    config_param :model_name, :string, default: "hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest"
    config_param :api_url, :string, default: "http://localhost:11434/api"
    config_param :prompt_template, :string
    config_param :field_name, :string, default: 'message'
    config_param :output_field, :string, default: 'llm_output'

    def configure(conf)
      super
    end

    def filter(tag, time, record)
      # Skip if input field doesn't exist
      return record unless record[@field_name]
      
      # Prepare prompt by replacing template variables
      prompt = @prompt_template.gsub(/<%= record\["([^"]+)"\] %>/) do
        record[$1] || ''
      end
      
      # Process with LLM
      processor = LLMAlfr::Processor.new(@model_name, @api_url)
      result = processor.process(prompt, record[@field_name])
      
      # Add result to record
      record[@output_field] = result
      
      record
    end
  end
end