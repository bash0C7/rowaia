require 'fluent/plugin/output'
require 'net/http'
require 'uri'

module Fluent::Plugin
  class SstpOutput < Output
    Fluent::Plugin.register_output('sstp', self)
    
    helpers :compat_parameters
    
    # Configuration parameters
    config_param :sstp_server, :string, default: '127.0.0.1'
    config_param :sstp_port, :integer, default: 9801
    config_param :request_method, :string, default: 'NOTIFY'
    config_param :request_version, :string, default: 'SSTP/1.1'
    config_param :sender, :string, default: 'Rowaia'
    config_param :script_template, :string
    
    config_section :buffer do
      config_set_default :@type, 'memory'
      config_set_default :flush_mode, :immediate
    end

    def configure(conf)
      compat_parameters_convert(conf, :buffer)
      super
    end

    def multi_workers_ready?
      true
    end

    def write(chunk)
      chunk.each do |time, record|
        # Prepare script by replacing template variables
        script = @script_template.gsub(/<%= record\["([^"]+)"\] %>/) do
          record[$1] || ''
        end
        
        # Send notification
        send_sstp_notification(script)
      end
    end
    
    private
    
    def send_sstp_notification(script)
      # Prepare SSTP request
      uri = URI.parse("http://#{@sstp_server}:#{@sstp_port}/")
      request = Net::HTTP::Post.new(uri.path)
      
      # SSTP headers and body
      request_content = "#{@request_method} #{@request_version}\r\n"
      request_content += "Sender: #{@sender}\r\n"
      request_content += "Script: #{script}\r\n"
      request_content += "\r\n"
      
      request.body = request_content
      request.content_type = 'text/plain'
      
      # Send request
      begin
        Net::HTTP.start(uri.hostname, uri.port) do |http|
          http.request(request)
        end
      rescue => e
        log.error "Failed to send SSTP notification", error: e.to_s
      end
    end
  end
end