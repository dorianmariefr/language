require "./spec_helper"

def eq_code(expected)
  eq([{:code => [expected]}])
end

template = Language.create do
  rule(:minus) { str("-") }
  rule(:plus) { str("+") }
  rule(:dot) { str(".") }
  rule(:e) { str("e") | str("E") }
  rule(:double_quote) { str("\"") }
  rule(:single_quote) { str("'") }
  rule(:escape) { str("\\") }
  rule(:opening_bracket) { str("{") }
  rule(:closing_bracket) { str("}") }
  rule(:opening_square_bracket) { str("[") }
  rule(:closing_square_bracket) { str("]") }
  rule(:comma) { str(",") }
  rule(:colon) { str(":") }
  rule(:space) { str(" ") }
  rule(:newline) { str("\n") }
  rule(:equal) { str("=") }
  rule(:left_caret) { str("<") }
  rule(:right_caret) { str(">") }

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

  rule(:whitespaces) { (space | newline).repeat }

  # name

  rule(:name_character) do
    space.absent >>
      newline.absent >>
      comma.absent >>
      colon.absent >>
      dot.absent >>
      opening_bracket.absent >>
      closing_bracket.absent >>
      opening_square_bracket.absent >>
      closing_square_bracket.absent >>
      equal.absent >>
      left_caret.absent >>
      right_caret.absent >>
      any
  end

  rule(:name) do
    name_character.repeat(1).aka(:name)
  end

  # nothing

  rule(:nothing) do
    str("nothing").aka(:nothing) | rule(:name)
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

  rule(:decimal) do
    dot.ignore >> digit.repeat(1)
  end

  rule(:exponent) do
    e >> sign.aka(:sign).maybe >> digit.repeat(1).aka(:whole)
  end

  rule(:number) do
    (
      minus.aka(:sign).maybe >>
        whole.aka(:whole) >>
        decimal.aka(:decimal).maybe >>
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

  # array

  rule(:array_element) do
    rule(:code)
  end

  rule(:array) do
    (
      opening_square_bracket.ignore >>
      whitespaces.ignore >>
      array_element.repeat(0, 1) >>
      (whitespaces >> comma >> whitespaces >> array_element).repeat >>
      whitespaces.ignore >>
      closing_square_bracket.ignore
    ).aka(:array) | string
  end

  # dictionnary

  rule(:dictionnary_key_value) do
    rule(:code).aka(:key) >>
      whitespaces >>
      (colon | (equal >> right_caret)) >>
      whitespaces >>
      rule(:code).aka(:value)
  end

  rule(:dictionnary) do
    (
      opening_bracket.ignore >>
      whitespaces.ignore >>
      dictionnary_key_value.repeat(0, 1) >>
      (whitespaces >> comma >> whitespaces >> dictionnary_key_value).repeat >>
      whitespaces.ignore >>
      closing_bracket.ignore
    ).aka(:dictionnary) | array
  end

  # call

  rule(:call) do
    (dictionnary.aka(:left) >> dot >> rule(:call).aka(:right)).aka(:call) | dictionnary
  end

  # statement

  rule(:statement) do
    call
  end

  # code

  rule(:code) do
    whitespaces >> statement.repeat(1) >> whitespaces
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
    part.repeat(1) | str("").aka(:text).repeat(1, 1)
  end
end

describe "template" do
  it %(parses "") do
    template.parse("").should eq([{:text => ""}])
  end

  it %(parses "Hello world") do
    template.parse("Hello world").should eq([{:text => "Hello world"}])
  end

  it %(parses "1 = {1}") do
    template.parse("1 = {1}").should eq(
      [
        {:text => "1 = "},
        {:code => [{:number => {:whole => "1"}}]},
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

  it %(parses "{user.first_name}") do
    template.parse("{user.first_name}").should eq_code({
      :call => {
        :left  => {:name => "user"},
        :right => {:name => "first_name"},
      },
    })
  end

  it %(parses "{user.first_name.upcase}") do
    template.parse("{user.first_name.upcase}").should eq_code({
      :call => {
        :left  => {:name => "user"},
        :right => {
          :call => {
            :left  => {:name => "first_name"},
            :right => {:name => "upcase"},
          },
        },
      },
    })
  end
end
