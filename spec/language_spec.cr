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

  context "string" do
    language = Language.create do
      rule(:a) do
        str("a")
      end

      root do
        # (double_quoted_string | single_quoted_string).aka(:string)
        a
      end

#       rule(:double_quoted_string) do
#         double_quote.ignore >> double_quoted_string_character.repeat >> double_quote.ignore
#       end
#
#       rule(:single_quoted_string) do
#         double_quote.ignore >> single_quoted_string_character.repeat >> single_quote.ignore
#       end
#
#       rule(:double_quote) { str("\"") }
#       rule(:single_quote) { str("'") }
#       rule(:escape) { str("\\") }
#
#       rule(:double_quoted_string_character) do
#         (double_quote.absent >> escape.absent >> any) |
#           (escape >> any)
#       end
#
#       rule(:single_quoted_string_character) do
#         (single_quote.absent >> escape.absent >> any) |
#           (escape >> any)
#       end
    end
  end
end
