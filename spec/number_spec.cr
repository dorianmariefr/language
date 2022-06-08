require "./spec_helper"

number = Language.create do
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
    dot >> digit.repeat
  end

  rule(:exponent) do
    e >> sign.aka(:sign).maybe >> digit.repeat.aka(:whole)
  end

  root do
    (
      minus.aka(:sign).maybe >>
        whole.aka(:whole) >>
        fraction.aka(:fraction).maybe >>
        exponent.aka(:exponent).maybe
    ).aka(:number)
  end
end

describe number do
  it "parses 0" do
    number.parse("0").should eq({ :number => "0" })
  end

  it "parses 1" do
    number.parse("1").should eq({ :number => "1" })
  end

  it "parses 1923" do
    number.parse("1923").should eq({ :number => "1923" })
  end
end
