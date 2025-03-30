require 'fluent/plugin/output'
require 'llmalfr'
require 'fileutils'
require 'json'
module Fluent
  module Plugin
    class ContextOutput < Output
      Fluent::Plugin.register_output('context', self)

#      helpers :compat_parameters, :formatter, :inject, :event_emitter

      # Support buffering
#      helpers :buffer

      desc 'Output path to write processed context'
      config_param :output_path, :string

      desc 'Ollama model name'
      config_param :model_name, :string, default: 'hf.co/elyza/Llama-3-ELYZA-JP-8B-GGUF:latest'

      desc 'Ollama API URL'
      config_param :api_url, :string, default: 'http://localhost:11434/api'

      desc 'Ollama Prompt'
      config_param :prompt, :string

      desc 'Custom LLM options in JSON format'
      config_param :options_json, :string, default: '{"temperature":1.5,"top_p":0.88,"top_k":80,"num_predict":-1,"repeat_penalty":1.5,"presence_penalty":0.2,"frequency_penalty":0.2,"stop":["\n\n","。\n"],"seed":-1}'

      def configure(conf)
        super

        @options = JSON.parse(@options_json)
        # Create output directory if it doesn't exist
        FileUtils.mkdir_p(@output_path) unless Dir.exist?(@output_path)
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
        full_context = messages.join(" ")
        # Process with LLM
        processor = LLMAlfr::Processor.new(@model_name, @api_url)
        
        begin
#          log.debug @prompt
#          log.debug full_context.force_encoding('utf-8')
          result = processor.process(@prompt, full_context.force_encoding('utf-8'), @options)
          
          # Write result to file
          log.debug result
          File.open(File.join(@output_path, "#{tag}"), "a") { |f| f.puts(result) }
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

#      def format(tag, time, record)
#        [time, record].to_msgpack
#      end

      # Multi-worker support
      def multi_workers_ready?
        true
      end
    end
  end
end
