require "./language/parser"
require "./language/atom"
require "./language/definition"

class Language
  VERSION = "0.1.0"

  @root : Atom
  @rules : Array(Atom)

  getter rules

  def initialize
    @rules = [] of Atom
    @root = Atom.new
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
    @root = with Definition.new(name: :root, language: self) yield
  end

  def rule(name, &block)
    @rules << with Definition.new(name: name, language: self) yield
  end

  def find_rule(name)
    if name == :root
      @root
    else
      @rules.detect { |rule| rule.name == name }
    end
  end
end
