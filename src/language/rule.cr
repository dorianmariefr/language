class Language
  class Rule
    def_clone

    getter name
    getter atom

    def initialize(@name : Symbol = :root, @atom : Atom? = nil)
    end

    def parse(parser)
      @atom.not_nil!.parse(parser) if @atom
    end
  end
end
