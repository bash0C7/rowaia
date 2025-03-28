require "helper"
require "fluent/plugin/in_context.rb"

class ContextInputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Input.new(Fluent::Plugin::ContextInput).configure(conf)
  end
end
