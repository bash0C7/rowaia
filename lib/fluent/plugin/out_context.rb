require 'fluent/plugin/output'
require 'llmalfr'
require 'fileutils'

module Fluent
  module Plugin
    class ContextOutput < Output
      Fluent::Plugin.register_output('context', self)

      helpers :compat_parameters, :buffer

      desc 'Output path to write processed context'
      config_param :output_path, :string

      desc 'Ollama model name'
      config_param :model_name, :string, default: 'hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest'

      desc 'Ollama API URL'
      config_param :api_url, :string, default: 'http://localhost:11434/api'

      def configure(conf)
        compat_parameters_convert(conf, :buffer)
        super

        # Create output directory if it doesn't exist
        FileUtils.mkdir_p(@output_path) unless Dir.exist?(@output_path)
      end

      def write(chunk)
        tag = chunk.metadata.tag

        # Collect all messages from the chunk
        messages = []
        chunk.each do |time, record|
          messages << record['message']
        end

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
end
