require "./spec_helper"

Code::Boolean = Language.create do
  root do
    (str("true") | str("false")).aka(:boolean)
  end
end

describe "boolean" do
  it %(parses "true") do
    Code::Boolean.parse("true").should eq({:boolean => "true"})
  end

  it %(parses "false") do
    Code::Boolean.parse("false").should eq({:boolean => "false"})
  end
end
