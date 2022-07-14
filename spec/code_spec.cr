require "./spec_helper"
require "./code"

describe "code" do
  it %(parses "{}") do
    Code::Parser.parse("{}").should eq([{ :dictionnary => "" }])
  end

  it %(parses "{"name":"Dorian"}") do
    Code::Parser.parse(%({"name":"Dorian"})).should eq([{
      :dictionnary => [
        {
          :key => [{ :string => "name" }],
          :value => [{ :string => "Dorian" }]
        }
      ]
    }])
  end

  it %(parses "{"name":"Dorian", age: 29}") do
    Code::Parser.parse(%({"name":"Dorian", age: 29})).should eq([{
      :dictionnary => [
        {
          :key => [{ :string => "name" }],
          :value => [{ :string => "Dorian" }]
        },
        {
          :key => "age",
          :value => [{ :integer => { :whole => "29" } }]
        }
      ]
    }])
  end

  it %(parses "{1: a, 2: b}") do
    Code::Parser.parse(%({1: a, 2: b})).should eq([{
      :dictionnary => [
        {
          :key => [{ :integer => { :whole => "1" }}],
          :value => [{ :name => "a" }]
        },
        {
          :key => [{ :integer => { :whole => "2" }}],
          :value => [{ :name => "b" }]
        },
      ]
    }])
  end

  it %(parses "{a: true\n, b: false , c: nothing}") do
    Code::Parser.parse(%({a: true\n, b: false , c: nothing})).should eq([{
      :dictionnary => [
        {
          :key => "a",
          :value => [{ :boolean => "true" }]
        },
        {
          :key => "b",
          :value => [{ :boolean => "false" }]
        },
        {
          :key => "c",
          :value => [{ :nothing => "nothing" }]
        },
      ]
    }])
  end

  it %(parses "{a: {b: {c: 1}}}") do
    Code::Parser.parse(%({a: {b: {c: 1}}})).should eq([{
      :dictionnary => [
        {
          :key => "a",
          :value => [{
            :dictionnary => [
              {
                :key => "b",
                :value => [{
                  :dictionnary => [
                    {
                      :key => "c",
                      :value => [
                        { :integer => { :whole => "1" } }
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
    Code::Parser.parse("[]").should eq([{ :array => "" }])
  end

  it %(parses "["Dorian"]") do
    Code::Parser.parse(%(["Dorian"])).should eq([{
      :array => [
        [{ :string => "Dorian" }]
      ]
    }])
  end

  it %(parses "[User.dorian, User.damien, User.laurie]") do
    Code::Parser.parse(%([User.dorian, User.damien, User.laurie])).should eq([{
      :array => [
        [{ :call => { :left => { :name => "User" }, :right => { :name => "dorian" } } }],
        [{ :call => { :left => { :name => "User" }, :right => { :name => "damien" } } }],
        [{ :call => { :left => { :name => "User" }, :right => { :name => "laurie" } } }],
      ]
    }])
  end

  it %(parses "0") do
    Code::Parser.parse("0").should eq([{ :integer => { :whole => "0" } }])
  end

  it %(parses "1") do
    Code::Parser.parse("1").should eq([{ :integer => { :whole => "1" } }])
  end

  it %(parses "1230") do
    Code::Parser.parse("1230").should eq([{ :integer => { :whole => "1230" } }])
  end

  it %(parses "0.1") do
    Code::Parser.parse("0.1").should eq([{ :decimal => { :whole => "0", :decimal => "1" } }])
  end
end
