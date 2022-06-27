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
        @parent.not_nil!.parse(parser) if @parent
        parser.consume(1)
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
      def initialize(@parent : Atom? = nil, @min : Int32 = 0, @max : Int32? = nil)
      end

      def parse(parser)
        return unless @parent

        @min.times do
          match(parser)
        end

        if @max.nil?
          begin
            loop do
              match(parser)
            end
          rescue Parser::Interuption
          end
        else
          (@max.not_nil! - @min).times do
            match(parser)
          end
        end
      end

      def to_s(io)
        min = @min.zero? ? "" : @min.to_s
        max = @max.nil? ? "" : ", #{@max}"
        parenthesis = min.empty? && max.empty? ? "" : "(#{min}#{max})"

        if @parent
          "#{@parent}.repeat#{parenthesis}".to_s(io)
        else
          "repeat#{parenthesis}".to_s(io)
        end
      end

      private def match(parser)
        clone = parser.copy(atom: self)
        clone.output = Output.new
        @parent.not_nil!.parse(clone)
        parser.cursor = clone.cursor
        parser.buffer = clone.buffer
        parser.output << clone.output
      end
    end

    class Str < Atom
      def initialize(@string : String, @parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser) if @parent

        if parser.next?(@string)
          parser.consume(@string.size)
        else
          raise Parser::Str::NotFound.new(parser, string: @string)
        end
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

    class Maybe < Atom
      def initialize(@parent : Atom? = nil)
      end

      def parse(parser)
        @parent.not_nil!.parse(parser) if @parent
      rescue Parser::Interuption
      end

      def to_s(io)
        if @parent
          "#{@parent}.maybe".to_s(io)
        else
          "maybe".to_s(io)
        end
      end
    end

    class Aka < Atom
      def initialize(@name : Symbol, @parent : Atom? = nil)
      end

      def parse(parser)
        clone = parser.copy(atom: self)

        if @parent
          clone.buffer = ""
          clone.output = Output.new
          @parent.not_nil!.parse(clone)
        end

        if clone.buffer?
          parser.output[@name] = Output.new(clone.buffer)
          parser.buffer = ""
        else
          parser.output = Output.new({ @name => clone.output })
        end

        parser.cursor = clone.cursor
      end

      def to_s(io)
        "aka(#{@name.inspect})".to_s(io)
      end
    end

    class Or < Atom
      def initialize(@left : Atom? = nil, @right : Atom? = nil)
      end

      def parse(parser)
        left_clone = parser.copy(atom: self)
        right_clone = parser.copy(atom: self)

        begin
          @left.not_nil!.parse(left_clone)
          parser.merge(left_clone)
        rescue Parser::Interuption
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
        @left.not_nil!.parse(parser)
        right_clone = parser.copy(atom: self)
        @right.not_nil!.parse(right_clone)
        parser.merge(right_clone)
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

    def maybe
      Maybe.new(parent: self)
    end

    def repeat(min = 0, max = nil)
      Repeat.new(parent: self, min: min, max: max)
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

    def inspect(io)
      to_s(io)
    end
  end
end
