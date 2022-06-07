require "spec"
require "../src/language"

macro expect_interupt
  expect_raises(Language::Parser::Interuption) do
    {{yield}}
  end
end

describe Language do
  context "text" do
    language = Language.create do
      root do
        any.repeat.aka(:text)
      end
    end

    it "parses" do
      language.parse("Hello World").should eq({:text => "Hello World"})
      language.parse("").should eq({:text => ""})
      language.parse("\n").should eq({:text => "\n"})
    end
  end

  context "nothing" do
    language = Language.create do
      root do
        str("nothing").aka(:nothing)
      end
    end

    it %(parses "nothing") do
      language.parse("nothing").should eq({:nothing => "nothing"})
    end

    it %(doesn't parse "anothing") do
      expect_interupt { language.parse("anothing") }
    end

    it %(doesn't parse "nothinga") do
      expect_interupt { language.parse("nothinga") }
    end
  end

  context "boolean" do
    language = Language.create do
      root do
        (str("true") | str("false")).aka(:boolean)
      end
    end

    it %(parses "true") do
      language.parse("true").should eq({:boolean => "true"})
    end

    it %(parses "false") do
      language.parse("false").should eq({:boolean => "false"})
    end
  end

  context "string" do
    language = Language.create do
      rule(:double_quote) { str("\"") }
      rule(:single_quote) { str("'") }
      rule(:escape) { str("\\") }

      rule(:double_quoted_string_character) do
        (double_quote.absent >> escape.absent >> any) |
          (escape >> any)
      end

      rule(:single_quoted_string_character) do
        (single_quote.absent >> escape.absent >> any) |
          (escape >> any)
      end

      rule(:double_quoted_string) do
        double_quote.ignore >> double_quoted_string_character.repeat >> double_quote.ignore
      end

      rule(:single_quoted_string) do
        single_quote.ignore >> single_quoted_string_character.repeat >> single_quote.ignore
      end

      root do
        (double_quoted_string | single_quoted_string).aka(:string)
      end
    end

    it %(parses "hello") do
      language.parse(%("hello")).should eq({:string => "hello"})
    end

    it %(parses "") do
      language.parse(%("")).should eq({:string => ""})
    end

    it %(parses 'hello') do
      language.parse(%('hello')).should eq({:string => "hello"})
    end

    it %(parses '') do
      language.parse(%('')).should eq({:string => ""})
    end

    it %(parses "hello\\nworld") do
      language.parse(%("hello\nworld")).should eq({:string => "hello\nworld"})
    end

    it %(parses 'hello\nworld') do
      language.parse(%('hello\nworld')).should eq({:string => "hello\nworld"})
    end

    it %(doesn't parses "\\") do
      expect_interupt { language.parse(%("\\")) }
    end

    it %(doesn't parses ") do
      expect_interupt { language.parse(%(")) }
    end

    it %(doesn't parses '\\') do
      expect_interupt { language.parse(%('\\')) }
    end

    it %(doesn't parses ') do
      expect_interupt { language.parse(%(')) }
    end

    it %(doesn't parses a) do
      expect_interupt { language.parse(%(a)) }
    end
  end
end
