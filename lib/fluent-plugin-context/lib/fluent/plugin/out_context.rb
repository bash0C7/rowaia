require 'fluent/plugin/output'
require 'llmalfr'
require 'fileutils'

module Fluent
  module Plugin
    class ContextOutput < Output
      Fluent::Plugin.register_output('context', self)

      helpers :compat_parameters, :formatter, :inject, :event_emitter

      # Support buffering
      helpers :buffer

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

      # For non-buffered operation (not recommended for production)
      def process(tag, es)
        # This method is kept for backward compatibility
        # It will be called when buffer is not configured
        messages = []
        es.each do |time, record|
          messages << record['message']
        end

        return if messages.empty?
        process_messages(tag, messages)
      end

      # For buffered operation
      def write(chunk)
        tag = chunk.metadata.tag
        
        # Collect all messages from the chunk
        messages = []
        chunk.each do |time, record|
          messages << record['message']
        end
        
        return if messages.empty?
        process_messages(tag, messages)
      end

      # Used by both buffered and non-buffered operations
      def process_messages(tag, messages)
        # Combine all messages into a single context
        full_context = messages.join("\n\n")
        
        # Process with LLM
        processor = LLMAlfr::Processor.new(@model_name, @api_url)
        prompt = "Summarize the following text concisely while preserving important information:"
        
        begin
          result = processor.process(prompt, full_context)
          
          # Write result to file
          output_file = File.join(@output_path, "#{tag}")
          File.write(output_file, result)
          log.info("Successfully processed and wrote context for tag: #{tag}")
        rescue => e
          log.error("Error processing context for tag: #{tag}", error: e.message, error_class: e.class.to_s)
          log.debug_backtrace(e.backtrace)
        end
      end

      # Default buffer configuration
      def buffer_section_stream_mode?
        false
      end

      def format(tag, time, record)
        [time, record].to_msgpack
      end

      # Multi-worker support
      def multi_workers_ready?
        true
      end
    end
  end
end
