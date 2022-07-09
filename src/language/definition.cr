class Language
  class Definition
    class RuleNotFound < Exception
    end

    @atom : Atom

    def initialize(@name : Symbol, @language : Language)
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

    def rule(name)
      Atom::Rule.new(name: name)
    end

    def find_atom!(name)
      @language.find_atom(name) ||
        raise(RuleNotFound.new("No atom found name #{name.inspect}"))
    end

    macro method_missing(method)
      def {{method}}
        find_atom!({{method.symbolize}})
      end
    end
  end
end
