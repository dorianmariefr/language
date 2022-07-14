class Template
end

Template::Parser = Language.create do
  rule(:escape) { str("\\") }
  rule(:opening_bracket) { str("{") }
  rule(:closing_bracket) { str("}") }

  rule(:code) { Code::Parser }

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

