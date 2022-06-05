class Language
  class Rule
    getter name
    getter atom

    def initialize(@name : Symbol = :root, @atom : Atom? = nil)
    end

    def parse(parser)
      @atom.not_nil!.parse(parser) if @atom
    end
  end
end
