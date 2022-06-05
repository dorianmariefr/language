require "./spec_helper"

describe Language do
  context "text" do
    language = Language.create do
      root do
        any.repeat.aka(:text)
      end
    end

    it "parses" do
      language.parse("Hello World").should eq({ :text => "Hello World" })
      language.parse("").should eq({ :text => "" })
      language.parse("\n").should eq({ :text => "\n" })
    end
  end
end
