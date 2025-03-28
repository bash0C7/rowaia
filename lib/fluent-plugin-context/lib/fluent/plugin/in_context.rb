

require "fluent/plugin/input"

module Fluent
  module Plugin
    class ContextInput < Fluent::Plugin::Input
      Fluent::Plugin.register_input("context", self)
    end
  end
end
