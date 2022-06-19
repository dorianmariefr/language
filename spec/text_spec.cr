require "./spec_helper"

Code::Text = Language.create do
  root do
    any.repeat.aka(:text)
  end
end

describe "text" do
  it %(parses "Hello World") do
    Code::Text.parse("Hello World").should eq({:text => "Hello World"})
  end

  it %(parses "") do
    Code::Text.parse("").should eq({:text => ""})
  end

  it %(parses "\n") do
    Code::Text.parse("\n").should eq({:text => "\n"})
  end
end
