class Language
  class Atom
    class None < Atom
      def initialize(@parent : Atom? = nil)
      end
    end

    class Any < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser) if @parent
        parser.consume(1)
      end
    end

    class Repeat < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        return parser unless @parent

        loop do
          @parent.not_nil!.parse(parser)
        end
      rescue Parser::Interuption
      end
    end

    class Str < Atom
      class NotFound < Parser::Interuption
      end

      def initialize(@string : String, @parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser) if @parent

        if parser.next?(@string)
          parser.consume(@string.size)
        else
          raise NotFound.new("expected #{@string}")
        end
      end
    end

    class Or < Atom
      def initialize(@left : Atom? = nil, @right : Atom? = nil)
      end

      def parse(parser)
        @left.not_nil!.parse(parser)
      rescue Parser::Interuption
        @right.not_nil!.parse(parser)
      end
    end

    class Aka < Atom
      def initialize(@name : Symbol, @parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser) if @parent
        parser.aka(@name)
      end
    end

    def initialize
    end

    def any
      Any.new
    end

    def str(string)
      Str.new(string)
    end

    def repeat
      Repeat.new(parent: self)
    end

    def aka(name)
      Aka.new(parent: self, name: name)
    end

    def |(other)
      Or.new(left: self, right: other)
    end

    def parse(parser)
      raise NotImplementedError.new("#{self.class}#parse")
    end
  end
end
