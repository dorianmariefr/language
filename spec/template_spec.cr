require "./spec_helper"

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

  # nothing

  rule(:nothing) do
    str("nothing").aka(:nothing)
  end

  # boolean

  rule(:boolean) do
    (str("true") | str("false")).aka(:boolean)
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
    ).aka(:number)
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
    (double_quoted_string | single_quoted_string).aka(:string)
  end

  # code

  rule(:code) do
    nothing | boolean | number | string
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
    template.parse("Hello world").should eq([{ :text => "Hello world" }])
  end

  it %(parses "1 = {1}") do
    template.parse("1 = {1}").should eq(
      [
        { :text => "1 = " },
        { :code => { :number => { :whole => "1" } } }
      ]
    )
  end
end
