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

  context "nothing" do
    language = Language.create do
      root do
        str("nothing").aka(:nothing)
      end
    end

    it %(parses "nothing") do
      language.parse("nothing").should eq({ :nothing => "nothing" })
    end

    it %(doesn't parse "anothing") do
      expect_raises(Language::Atom::Str::NotFound) do
        language.parse("anothing")
      end
    end

    it %(doesn't parse "nothinga") do
      expect_raises(Language::Parser::NotEndOfInput) do
        language.parse("nothinga")
      end
    end
  end

  context "boolean" do
    language = Language.create do
      root do
        (str("true") | str("false")).aka(:boolean)
      end
    end

    it %(parses "true") do
      language.parse("true").should eq({ :boolean => "true" })
    end

    it %(parses "false") do
      language.parse("false").should eq({ :boolean => "false" })
    end
  end
end
