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
        parser.any
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
      def initialize(@string : String, @parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser) if @parent
        parser.str(@string)
      end
    end

    class Absent < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser.dup) if @parent
      rescue Parser::Interuption
      else
        raise Parser::Interuption.new(parser)
      end
    end

    class Ignore < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser.dup) if @parent
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

    class Or < Atom
      def initialize(@left : Atom? = nil, @right : Atom? = nil)
      end

      def parse(parser)
        @left.not_nil!.parse(parser)
      rescue Parser::Interuption
        @right.not_nil!.parse(parser)
      end
    end

    class And < Atom
      def initialize(@left : Atom? = nil, @right : Atom? = nil)
      end

      def parse(parser)
        @left.not_nil!.parse(parser)
        @right.not_nil!.parse(parser)
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

    def absent
      Absent.new(parent: self)
    end

    def ignore
      Ignore.new(parent: self)
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

    def >>(other)
      And.new(left: self, right: other)
    end

    def <<(other)
      And.new(left: self, right: other)
    end

    def parse(parser)
      raise NotImplementedError.new("#{self.class}#parse")
    end
  end
end
