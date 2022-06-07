require "colorize"

class Language
  class Atom
    def_clone

    class None < Atom
      def initialize(@parent : Atom? = nil)
      end
    end

    class Any < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        @parent.not_nil!.parse(parser) if @parent
        parser.any
      end

      def to_s(io)
        if @parent
          "#{@parent}.any".to_s(io)
        else
          "any".to_s(io)
        end
      end
    end

    class Repeat < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        return parser unless @parent

        loop do
          @parent.not_nil!.parse(parser)
        end
      rescue Parser::Interuption
      end

      def to_s(io)
        if @parent
          "#{@parent}.repeat".to_s(io)
        else
          "repeat".to_s(io)
        end
      end
    end

    class Str < Atom
      def initialize(@string : String, @parent : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        @parent.not_nil!.parse(parser) if @parent
        parser.str(@string)
      end

      def to_s(io)
        if @parent
          "#{@parent}.str(#{@string.inspect})".to_s(io)
        else
          "str(#{@string.inspect})".to_s(io)
        end
      end
    end

    class Absent < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        clone = parser.copy(atom: self)
        @parent.not_nil!.parse(clone) if @parent
      rescue Parser::Interuption
      else
        raise Parser::Interuption.new(parser)
      end

      def to_s(io)
        if @parent
          "#{@parent}.absent".to_s(io)
        else
          "absent".to_s(io)
        end
      end
    end

    class Ignore < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        clone = parser.copy(atom: self)
        @parent.not_nil!.parse(clone) if @parent
        parser.cursor = clone.cursor
      end

      def to_s(io)
        if @parent
          "#{@parent}.ignore".to_s(io)
        else
          "ignore".to_s(io)
        end
      end
    end

    class Aka < Atom
      def initialize(@name : Symbol, @parent : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        @parent.not_nil!.parse(parser) if @parent
        parser.aka(@name)
      end

      def to_s(io)
        "aka(#{@name.inspect})".to_s(io)
      end
    end

    class Or < Atom
      def initialize(@left : Atom? = nil, @right : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        left_clone = parser.copy(atom: self)
        right_clone = parser.copy(atom: self)

        begin
          @left.not_nil!.parse(left_clone)
          parser.merge(left_clone)
        rescue Parser::Interuption
          debug "#{parser.h} atom #{self} #{"interupted".colorize(:red)}"
          @right.not_nil!.parse(right_clone)
          parser.merge(right_clone)
        end
      end

      def to_s(io)
        "((#{@left}) | (#{@right}))".to_s(io)
      end
    end

    class And < Atom
      def initialize(@left : Atom? = nil, @right : Atom? = nil)
      end

      def parse(parser)
        debug "#{parser.h} atom #{self}"
        @left.not_nil!.parse(parser)
        @right.not_nil!.parse(parser)
      end

      def to_s(io)
        "#{@left} >> #{@right}".to_s(io)
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
