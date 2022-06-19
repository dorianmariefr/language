require "./spec_helper"

text = Language.create do
  root do
    any.repeat
  end
end

describe "text" do
  it %(parses "Hello World") do
    text.parse("Hello World").should eq("Hello World")
  end

  it %(parses "") do
    text.parse("").should eq("")
  end

  it %(parses "\n") do
    text.parse("\n").should eq("\n")
  end
end
