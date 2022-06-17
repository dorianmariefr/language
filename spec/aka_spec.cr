require "./spec_helper"

aka = Language.create do
  root do
    str("e") >> str("1").aka(:whole)
  end
end

describe "aka" do
  it %(parses "e1") do
    aka.parse("e1").should eq({:whole => "1"})
  end
end
