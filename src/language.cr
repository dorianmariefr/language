require "./language/parser/interuption"
require "./language/parser"
require "./language/atom"
require "./language/definition"
require "./language/rule"
require "./language/output"

class Language
  VERSION = version

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

  def parse(parser : Parser)
    clone = Parser.new(
      root: @root,
      rules: @rules,
      input: parser.input,
      cursor: parser.cursor,
      buffer: parser.buffer,
      output: parser.output
    )

    clone.parse(check_end_of_input: false)

    parser.cursor = clone.cursor
    parser.buffer = clone.buffer
    parser.output = clone.output
  end

  def parse(input : String) : Output
    Parser.new(root: @root, rules: @rules, input: input).parse
  end

  def root(&block) : Nil
    atom = with Definition.new(name: :root, language: self) yield
    @root = Rule.new(atom: atom)
    nil
  end

  def rule(name, &block) : Nil
    atom = with Definition.new(name: name, language: self) yield
    @rules << Rule.new(name: name, atom: atom)
    nil
  end

  def find_rule(name) : Rule?
    (@rules + [@root]).find { |rule| rule.name == name }
  end

  def find_atom(name) : (Atom | Language)?
    rule = find_rule(name)
    rule ? rule.not_nil!.atom : nil
  end

  def absent
    Atom::Absent.new(parent: self)
  end

  def ignore
    Atom::Ignore.new(parent: self)
  end

  def maybe
    Atom::Maybe.new(parent: self)
  end

  def repeat(min = 0, max = nil)
    Atom::Repeat.new(parent: self, min: min, max: max)
  end

  def aka(name)
    Atom::Aka.new(parent: self, name: name)
  end

  def |(other)
    Atom::Or.new(left: self, right: other)
  end

  def >>(other)
    Atom::And.new(left: self, right: other)
  end

  def <<(other)
    Atom::And.new(left: self, right: other)
  end
end
