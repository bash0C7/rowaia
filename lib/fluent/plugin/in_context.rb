require 'fluent/plugin/input'
require 'fileutils'

module Fluent::Plugin
  class ContextInput < Input
    Fluent::Plugin.register_input('context', self)

    # Configuration parameters
    config_param :path, :string
    config_param :tag, :string, default: nil
    config_param :run_interval, :time, default: 1800 # 30 minutes

    def configure(conf)
      super
      @path = File.expand_path(@path)
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
          # Minimal error logging
          log.error "Failed to process file: #{file}", error: e.to_s
        end
      end
    end
  end
end