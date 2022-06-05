require "./language/*"

class Language
  VERSION = "0.1.0"

  @root : Atom

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
    @root = with Definition.new(:root) yield
  end

  def rule(name, &block)
    @rules = with Definition.new(name) yield
  end
end
