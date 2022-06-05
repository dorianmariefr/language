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
      {% if method != method %}
        {% p method %}
        def {{method}}
          @language.find_rule(method)
        end
      {% end %}
    end
  end
end
