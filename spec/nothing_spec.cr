require "./spec_helper"

nothing = Language.create do
  root do
    str("nothing").aka(:nothing)
  end
end

describe "nothing" do
  it %(parses "nothing") do
    nothing.parse("nothing").should eq({:nothing => "nothing"})
  end

  it %(doesn't parse "anothing") do
    expect_interupt { nothing.parse("anothing") }
  end

  it %(doesn't parse "nothinga") do
    expect_interupt { nothing.parse("nothinga") }
  end
end
