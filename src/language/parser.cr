require "colorize"

COLORS = [
  :default,
  :black,
  :red,
  :green,
  :yellow,
  :blue,
  :magenta,
  :cyan,
  :light_gray,
  :dark_gray,
  :light_red,
  :light_green,
  :light_yellow,
  :light_blue,
  :light_magenta,
  :light_cyan,
  :white,
]

class Language
  class Parser
    def_clone

    class Interuption < Exception
      def initialize(@parser : Parser)
      end

      def message
        "#{input}\n#{" " * cursor}^\n"
      end

      private def cursor
        @parser.cursor
      end

      private def input
        @parser.input
      end
    end

    class EndOfInput < Interuption
    end

    class NotEndOfInput < Interuption
    end

    class Absent
      class Present < Interuption
      end
    end

    class Str
      class NotFound < Interuption
        def initialize(@parser : Parser, @string : String)
        end

        def message
          "#{@string} not found\n#{super}"
        end
      end
    end

    alias Output = String |
                   Hash(Symbol, Output)

    getter input : String
    getter buffer : String
    getter output : Output
    property root : Rule
    property cursor : Int32

    @output : Output

    def initialize(@root : Rule, @rules : Array(Rule), @input : String, @cursor = 0)
      @output = {} of Symbol => Output
      @buffer = ""
    end

    def copy(atom)
      clone = self.clone
      clone.root = Rule.new(atom: atom)
      clone.cursor = @cursor
      clone
    end

    def merge(parser)
      @cursor = parser.cursor
      @buffer = parser.buffer
      @output = parser.output
    end

    def parse
      debug "#{h} parser parse"
      @root.parse(self)

      if @cursor == @input.size
        @output
      else
        raise NotEndOfInput.new(self)
      end
    end

    def any
      debug "#{h} parser any"
      consume(1)
    end

    def repeat
      debug "#{h} parser repeat"
      loop do
        @parent.not_nil!.parse(self)
      end
    rescue Interuption
    end

    def str(string)
      debug "#{h} parser str(#{string.inspect})"
      if next?(string)
        debug "#{h} parser str(#{string.inspect}) found"
        consume(string.size)
      else
        debug "#{h} parser str(#{string.inspect}) not found"
        raise Str::NotFound.new(self, string: string)
      end
    end

    def consume(n)
      debug "#{h} parser consume(#{n})"
      if @cursor + n <= @input.size
        @buffer += @input[@cursor...(@cursor + n)]
        @cursor += n
        debug "#{h} parser consume(#{n}) (buffer = #{@buffer.inspect})"
      else
        raise EndOfInput.new(self)
      end
    end

    def aka(name)
      debug "#{h} parser aka(#{name.inspect})"
      if @output.is_a?(String)
        @output = {} of Symbol => Output
      end

      @output.as(Hash(Symbol, Output))[name] = @buffer
      @buffer = ""
    end

    def next?(string)
      debug "#{h} parser next?(#{string.inspect})"
      @input[@cursor...(@cursor + string.size)] == string
    end

    def buffer?
      !!@buffer.presence
    end

    def h
      hash.to_s[0..3].colorize(COLORS[hash % COLORS.size])
    end
  end
end
