# Rowaia Developer Guide

## Build & Test Commands
- `bundle install` - Install dependencies
- `rake test` - Run all tests
- `ruby -I lib:test test/path/to/test_file.rb` - Run a single test file
- `ruby -I lib:test test/path/to/test_file.rb -n test_method_name` - Run a specific test

## Code Style Guidelines
- **Structure**: Follow Fluentd plugin architecture patterns
- **Naming**: Use snake_case for methods/variables, CamelCase for classes
- **Modules**: Namespace classes under `Fluent::Plugin`
- **Error Handling**: Use begin/rescue blocks with specific error logging
- **Comments**: Document parameters with `desc` before config_param
- **Configuration**: Use config_param with type and defaults
- **Logging**: Use log.info, log.error with context (tag, error details)
- **Files**: Organize input/output plugins in lib/fluent/plugin/
- **Testing**: Write Test::Unit tests following Fluentd test helpers

## Architecture
This project implements Fluentd plugins for context handling in an OODA loop architecture.

