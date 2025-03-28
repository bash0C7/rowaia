

require "fluent/plugin/output"

module Fluent
  module Plugin
    class ContextOutput < Fluent::Plugin::Output
      Fluent::Plugin.register_output("context", self)
    end
  end
end
