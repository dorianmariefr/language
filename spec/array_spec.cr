require "./spec_helper"
require "./nothing_spec"
require "./boolean_spec"
require "./string_spec"
require "./number_spec"

Code::Array = Language.create do
  rule(:element) do
    Code::Nothing | Code::Boolean | Code::String | Code::Number
  end

  root do
    element.repeat.aka(:array)
  end
end

describe "array" do
  it "compiles :)" do
    Code::Array.parse("1")
  end
end
