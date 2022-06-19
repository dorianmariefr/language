require "./spec_helper"

Code::Nothing = Language.create do
  root do
    str("nothing").aka(:nothing)
  end
end

describe "nothing" do
  it %(parses "nothing") do
    Code::Nothing.parse("nothing").should eq({:nothing => "nothing"})
  end

  it %(doesn't parse "anothing") do
    expect_interupt { Code::Nothing.parse("anothing") }
  end

  it %(doesn't parse "nothinga") do
    expect_interupt { Code::Nothing.parse("nothinga") }
  end
end
