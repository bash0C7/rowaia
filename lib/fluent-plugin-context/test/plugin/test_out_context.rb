require "helper"
require "fluent/plugin/out_context.rb"

class ContextOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::ContextOutput).configure(conf)
  end
end
