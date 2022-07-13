require "./spec_helper"

code = Language.create do
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

  root do
    rule(:code)
  end
end

describe "code" do
  it %(parses "{}") do
    code.parse("{}").should eq([{ :dictionnary => "" }])
  end

  it %(parses "{"name":"Dorian"}") do
    code.parse(%({"name":"Dorian"})).should eq([{
      :dictionnary => [
        {
          :key => [{ :string => "name" }],
          :value => [{ :string => "Dorian" }]
        }
      ]
    }])
  end

  it %(parses "{"name":"Dorian", age: 29}") do
    code.parse(%({"name":"Dorian", age: 29})).should eq([{
      :dictionnary => [
        {
          :key => [{ :string => "name" }],
          :value => [{ :string => "Dorian" }]
        },
        {
          :key => [{ :name => "age" }],
          :value => [{ :number => { :whole => "29" } }]
        }
      ]
    }])
  end

  it %(parses "{1: a, 2: b}") do
    code.parse(%({1: a, 2: b})).should eq([{
      :dictionnary => [
        {
          :key => [{ :number => { :whole => "1" }}],
          :value => [{ :name => "a" }]
        },
        {
          :key => [{ :number => { :whole => "2" }}],
          :value => [{ :name => "b" }]
        },
      ]
    }])
  end

  it %(parses "{a: true\n, b: false , c: nothing}") do
    code.parse(%({a: true\n, b: false , c: nothing})).should eq([{
      :dictionnary => [
        {
          :key => [{ :name => "a" }],
          :value => [{ :boolean => "true" }]
        },
        {
          :key => [{ :name => "b" }],
          :value => [{ :boolean => "false" }]
        },
        {
          :key => [{ :name => "c" }],
          :value => [{ :nothing => "nothing" }]
        },
      ]
    }])
  end

  it %(parses "{a: {b: {c: 1}}}") do
    code.parse(%({a: {b: {c: 1}}})).should eq([{
      :dictionnary => [
        {
          :key => [{ :name => "a" }],
          :value => [{
            :dictionnary => [
              {
                :key => [{ :name => "b" }],
                :value => [{
                  :dictionnary => [
                    {
                      :key => [{ :name => "c" }],
                      :value => [
                        { :number => { :whole => "1" } }
                      ]
                    },
                  ]
                }]
              },
            ]
          }]
        },
      ]
    }])
  end

  it %(parses "[]") do
    code.parse("[]").should eq([{ :array => "" }])
  end

  it %(parses "["Dorian"]") do
    code.parse(%(["Dorian"])).should eq([{
      :array => [
        [{ :string => "Dorian" }]
      ]
    }])
  end

  it %(parses "[User.dorian, User.damien, User.laurie]") do
    code.parse(%([User.dorian, User.damien, User.laurie])).should eq([{
      :array => [
        [{ :call => { :left => { :name => "User" }, :right => { :name => "dorian" } } }],
        [{ :call => { :left => { :name => "User" }, :right => { :name => "damien" } } }],
        [{ :call => { :left => { :name => "User" }, :right => { :name => "laurie" } } }],
      ]
    }])
  end
end
