require "./language/parser/interuption"
require "./language/parser"
require "./language/atom"
require "./language/definition"
require "./language/rule"
require "./language/output"

class Language
  def_clone

  VERSION = "0.1.0"

  @root : Rule
  @rules : Array(Rule)

  getter rules

  def initialize
    @rules = [] of Rule
    @root = Rule.new
  end

  def self.create(&block)
    instance = new
    with instance yield
    instance
  end

  def parse(input)
    Parser.new(root: @root, rules: @rules, input: input).parse
  end

  def root(&block)
    atom = with Definition.new(name: :root, language: self) yield
    @root = Rule.new(atom: atom)
  end

  def rule(name, &block)
    atom = with Definition.new(name: name, language: self) yield
    @rules << Rule.new(name: name, atom: atom)
  end

  def find_rule(name)
    (@rules + [@root]).find { |rule| rule.name == name }
  end

  def find_atom(name)
    rule = find_rule(name)
    rule ? rule.not_nil!.atom : nil
  end
end
