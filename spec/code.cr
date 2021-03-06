class Code
end

Code::Parser = Language.create do
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

  rule(:nothing_keyword) { str("nothing") }
  rule(:nil_keyword) { str("nil") }
  rule(:null_keyword) { str("null") }
  rule(:true_keyword) { str("true") }
  rule(:false_keyword) { str("false") }

  rule(:whitespaces) { (space | newline).repeat }

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

  # name

  rule(:name_character) do
    space.absent >>
      newline.absent >>
      comma.absent >>
      colon.absent >>
      dot.absent >>
      single_quote.absent >>
      double_quote.absent >>
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
    digit.absent >> name_character >> name_character.repeat
  end

  # nothing

  rule(:nothing) do
    (nothing_keyword | nil_keyword | null_keyword).aka(:nothing) | rule(:name).aka(:name)
  end

  # boolean

  rule(:boolean) do
    (true_keyword | false_keyword).aka(:boolean) | nothing
  end

  # integer

  rule(:integer_exponent) do
    e >> rule(:integer)
  end

  rule(:integer) do
    (
      sign.aka(:sign).maybe >>
        whole.aka(:whole) >>
        integer_exponent.aka(:exponent).maybe
    ).aka(:integer) | boolean
  end

  # decimal

  rule(:decimal_decimal) do
    dot.ignore >> digit.repeat(1)
  end

  rule(:decimal_exponent) do
    e >> rule(:decimal)
  end

  rule(:decimal) do
    (
      sign.aka(:sign).maybe >>
        whole.aka(:whole) >>
        decimal_decimal.aka(:decimal) >>
        decimal_exponent.aka(:exponent).maybe
    ).aka(:decimal) | integer
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
    (double_quoted_string | single_quoted_string).aka(:string) | decimal
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

  rule(:dictionnary_key) do
    (
      rule(:name).aka(:key) >> colon
    ) | (
      rule(:code).aka(:key) >> (colon | (whitespaces >> equal >> right_caret))
    )
  end

  rule(:dictionnary_key_value) do
    dictionnary_key >>
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
