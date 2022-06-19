require "./spec_helper"

text = Language.create do
  root do
    any.repeat.aka(:text)
  end
end

describe "text" do
  it %(parses "Hello World") do
    text.parse("Hello World").should eq({:text => "Hello World"})
  end

  it %(parses "") do
    text.parse("").should eq({:text => ""})
  end

  it %(parses "\n") do
    text.parse("\n").should eq({:text => "\n"})
  end
end
