require "./spec_helper"

def eq_code(expected)
  eq([{:code => expected}])
end

template = Language.create do
  rule(:minus) { str("-") }
  rule(:plus) { str("+") }
  rule(:dot) { str(".") }
  rule(:e) { str("e") | str("E") }
  rule(:zero) { str("0") }
  rule(:one) { str("1") }
  rule(:two) { str("2") }
  rule(:three) { str("3") }
  rule(:four) { str("4") }
  rule(:five) { str("5") }
  rule(:six) { str("6") }
  rule(:seven) { str("7") }
  rule(:eight) { str("8") }
  rule(:nine) { str("9") }
  rule(:double_quote) { str("\"") }
  rule(:single_quote) { str("'") }
  rule(:escape) { str("\\") }
  rule(:opening_bracket) { str("{") }
  rule(:closing_bracket) { str("}") }

  # name

  rule(:name) do
    (dot.absent >> opening_bracket.absent >> closing_bracket.absent >> any).repeat.aka(:name)
  end

  # nothing

  rule(:nothing) do
    str("nothing").aka(:nothing) | name
  end

  # boolean

  rule(:boolean) do
    (str("true") | str("false")).aka(:boolean) | nothing
  end

  # number

  rule(:positive_digit) do
    one | two | three | four | five | six | seven | eight | nine
  end

  rule(:digit) do
    zero | one | two | three | four | five | six | seven | eight | nine
  end

  rule(:sign) do
    plus | minus
  end

  rule(:whole) do
    zero | (positive_digit >> digit.repeat)
  end

  rule(:fraction) do
    dot.ignore >> digit.repeat(1)
  end

  rule(:exponent) do
    e >> sign.aka(:sign).maybe >> digit.repeat(1).aka(:whole)
  end

  rule(:number) do
    (
      minus.aka(:sign).maybe >>
        whole.aka(:whole) >>
        fraction.aka(:fraction).maybe >>
        exponent.aka(:exponent).maybe
    ).aka(:number) | boolean
  end

  # string

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

  rule(:string) do
    (double_quoted_string | single_quoted_string).aka(:string) | number
  end

  # call

  rule(:call) do
    (string.aka(:left) >> dot >> string.aka(:right)).aka(:call) | string
  end

  # code

  rule(:code) do
    call
  end

  # text

  rule(:text_character) do
    (opening_bracket.absent >> any) |
      (escape.ignore >> opening_bracket)
  end

  rule(:text) do
    text_character.repeat(1)
  end

  # part

  rule(:part) do
    text.aka(:text) | (opening_bracket >> code.aka(:code) >> closing_bracket)
  end

  # template

  root do
    part.repeat(1)
  end
end

describe "template" do
  it %(parses "Hello world") do
    template.parse("Hello world").should eq([{:text => "Hello world"}])
  end

  it %(parses "1 = {1}") do
    template.parse("1 = {1}").should eq(
      [
        {:text => "1 = "},
        {:code => {:number => {:whole => "1"}}},
      ]
    )
  end

  it %(parses "{1}") do
    template.parse("{1}").should eq_code({:number => {:whole => "1"}})
  end

  it %(parses "{"hello"}") do
    template.parse("{\"hello\"}").should eq_code({:string => "hello"})
  end

  it %(parses "{true}") do
    template.parse("{true}").should eq_code({:boolean => "true"})
  end

  it %(parses "{nothing}") do
    template.parse("{nothing}").should eq_code({:nothing => "nothing"})
  end

  it %(parses "{first_name}") do
    template.parse("{first_name}").should eq_code({:name => "first_name"})
  end
end
