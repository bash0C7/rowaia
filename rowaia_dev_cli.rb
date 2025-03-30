#!/usr/bin/env ruby
# rowaia_dev_cli.rb - CLI tool for testing LLM prompts with LLMAlfr

require 'llmalfr'
require 'json'
require 'optparse'

# Default settings
model_name = 'gemma3:1b'
api_url = 'http://localhost:11434/api'

# Parse command-line options
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{File.basename($0)} [options] OPTIONS_JSON PROMPT"
  
  opts.on('--model_name MODEL', 'Model name (default: gemma3:1b)') do |model|
    model_name = model
  end
  
  opts.on('--api_url URL', 'Ollama API URL (default: http://localhost:11434/api)') do |url|
    api_url = url
  end
  
  opts.on('-h', '--help', 'Display help') do
    puts opts
    exit
  end
end

begin
  opt_parser.parse!
  
  # Validate required positional arguments
  if ARGV.size < 2
    puts "Error: Required arguments missing"
    puts opt_parser
    exit 1
  end
  
  options_json = ARGV[0]
  prompt = ARGV[1]
rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
  puts "Error: #{e.message}"
  puts opt_parser
  exit 1
end

# Parse LLM options from JSON
begin
  llm_options = JSON.parse(options_json)
rescue JSON::ParserError => e
  puts "Error: Invalid JSON format: #{e.message}"
  exit 1
end

# Read context from standard input
context = $stdin.read.strip

# Process with LLMAlfr
begin
  processor = LLMAlfr::Processor.new(model_name, api_url)
  result = processor.process(prompt, context, llm_options)
  puts result
rescue => e
  puts "Error: #{e.class} - #{e.message}"
  exit 1
end