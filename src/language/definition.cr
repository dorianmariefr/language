class Language
  class Definition
    @name : Symbol
    @atom : Atom

    def initialize(name)
      @name = name
      @atom = Atom.new
    end

    def any
      @atom = Atom::Any.new
    end

    def str(string)
      @atom = Atom::Str.new(string: string)
    end

    def parse(input)
      @atom.parse(input)
    end
  end
end
