require 'fluent/plugin/input'

module Fluent
  module Plugin
    class ContextInput < Input
      Fluent::Plugin.register_input('context', self)

      desc 'Path to the context files directory'
      config_param :path, :string

      desc 'Tag for the emitted events'
      config_param :tag, :string, default: nil

      desc 'Run interval in seconds'
      config_param :run_interval, :time, default: 1800 # 30 minutes

      def configure(conf)
        super
        raise Fluent::ConfigError, "path parameter is required" unless @path
      end

      def start
        super
        @running = true
        @thread = Thread.new(&method(:run))
      end

      def shutdown
        @running = false
        @thread.join
        super
      end

      def run
        while @running
          process_files
          sleep @run_interval
        end
      end

      def process_files
        Dir.glob(File.join(@path, '*')).each do |file|
          next if File.directory?(file)
          
          begin
            content = File.read(file)
            emit_tag = @tag || File.basename(file, '.*')
            time = Fluent::Engine.now
            record = { 'message' => content, 'file' => file }
            router.emit(emit_tag, time, record)
          rescue => e
            log.error "Failed to process file: #{file}", error: e.to_s
          end
        end
      end
    end
  end
end
