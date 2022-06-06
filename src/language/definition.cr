class Language
  class Definition
    class NoRuleFound < Exception
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

    macro method_missing(method)
      def {{method}}
        @language.find_atom({{method.symbolize}}) ||
          raise NoRuleFound.new({{method.stringify}})
      end
    end
  end
end
