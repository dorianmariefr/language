require "./spec_helper"

text = Language.create do
  root do
    any.repeat.aka(:text)
  end
end

describe text do
  it "parses" do
    text.parse("Hello World").should eq({:text => "Hello World"})
    text.parse("").should eq({:text => ""})
    text.parse("\n").should eq({:text => "\n"})
  end
end
