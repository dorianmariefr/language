require "./spec_helper"
require "./code"
require "./template"

def eq_code(expected)
  eq([{:code => [expected]}])
end

describe "template" do
  it %(parses "") do
    Template::Parser.parse("").should eq([{:text => ""}])
  end

  it %(parses "Hello world") do
    Template::Parser.parse("Hello world").should eq([{:text => "Hello world"}])
  end

  it %(parses "1 = {1}") do
    Template::Parser.parse("1 = {1}").should eq(
      [
        {:text => "1 = "},
        {:code => [{:number => {:whole => "1"}}]},
      ]
    )
  end

  it %(parses "{1}") do
    Template::Parser.parse("{1}").should eq_code({:number => {:whole => "1"}})
  end

  it %(parses "{"hello"}") do
    Template::Parser.parse("{\"hello\"}").should eq_code({:string => "hello"})
  end

  it %(parses "{true}") do
    Template::Parser.parse("{true}").should eq_code({:boolean => "true"})
  end

  it %(parses "{nothing}") do
    Template::Parser.parse("{nothing}").should eq_code({:nothing => "nothing"})
  end

  it %(parses "{first_name}") do
    Template::Parser.parse("{first_name}").should eq_code({:name => "first_name"})
  end

  it %(parses "{user.first_name}") do
    Template::Parser.parse("{user.first_name}").should eq_code({
      :call => {
        :left  => {:name => "user"},
        :right => {:name => "first_name"},
      },
    })
  end

  it %(parses "{user.first_name.upcase}") do
    Template::Parser.parse("{user.first_name.upcase}").should eq_code({
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
