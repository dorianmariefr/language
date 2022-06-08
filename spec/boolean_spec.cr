require "./spec_helper"

boolean = Language.create do
  root do
    (str("true") | str("false")).aka(:boolean)
  end
end

describe boolean do
  it %(parses "true") do
    boolean.parse("true").should eq({:boolean => "true"})
  end

  it %(parses "false") do
    boolean.parse("false").should eq({:boolean => "false"})
  end
end
