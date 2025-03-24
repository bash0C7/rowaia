require 'fluent/plugin/output'
require 'llmalfr'
require 'fileutils'

module Fluent::Plugin
  class ContextOutput < Output
    Fluent::Plugin.register_output('context', self)

    helpers :compat_parameters

    # Configuration parameters
    config_param :buffer_type, :string, default: 'memory'
    config_param :buffer_path, :string, default: nil
    config_param :output_path, :string
    config_param :model_name, :string, default: "hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest"
    config_param :api_url, :string, default: "http://localhost:11434/api"
    
    config_section :buffer do
      config_set_default :@type, 'memory'
      config_set_default :chunk_keys, ['tag']
      config_set_default :timekey, 1800 # 30 minutes
    end

    def configure(conf)
      compat_parameters_convert(conf, :buffer)
      super
      @output_path = File.expand_path(@output_path)
      FileUtils.mkdir_p(@output_path) unless Dir.exist?(@output_path)
    end

    def multi_workers_ready?
      true
    end

    def write(chunk)
      tag = chunk.metadata.tag
      
      # Collect all messages from the chunk
      messages = []
      chunk.each do |time, record|
        messages << record['message']
      end
      
      # Skip if no messages
      return if messages.empty?
      
      # Combine all messages into a single context
      full_context = messages.join("\n\n")
      
      # Process with LLM
      processor = LLMAlfr::Processor.new(@model_name, @api_url)
      prompt = "Summarize the following text concisely while preserving important information:"
      result = processor.process(prompt, full_context)
      
      # Write result to file
      output_file = File.join(@output_path, "#{tag}")
      File.write(output_file, result)
    end
  end
end