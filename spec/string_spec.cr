require "./spec_helper"

string = Language.create do
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

describe "string" do
  it %(parses "hello") do
    string.parse(%("hello")).should eq({:string => "hello"})
  end

  it %(parses "") do
    string.parse(%("")).should eq({:string => ""})
  end

  it %(parses 'hello') do
    string.parse(%('hello')).should eq({:string => "hello"})
  end

  it %(parses '') do
    string.parse(%('')).should eq({:string => ""})
  end

  it %(parses "hello\\nworld") do
    string.parse(%("hello\nworld")).should eq({:string => "hello\nworld"})
  end

  it %(parses 'hello\nworld') do
    string.parse(%('hello\nworld')).should eq({:string => "hello\nworld"})
  end

  it %(doesn't parses "\\") do
    expect_interupt { string.parse(%("\\")) }
  end

  it %(doesn't parses ") do
    expect_interupt { string.parse(%(")) }
  end

  it %(doesn't parses '\\') do
    expect_interupt { string.parse(%('\\')) }
  end

  it %(doesn't parses ') do
    expect_interupt { string.parse(%(')) }
  end

  it %(doesn't parses a) do
    expect_interupt { string.parse(%(a)) }
  end
end
