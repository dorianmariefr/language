class Language
  class Parser
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

    getter cursor : Int32
    getter input : String

    @output : Output

    def initialize(@root : Rule, @rules : Array(Rule), @input : String, @cursor = 0)
      @output = {} of Symbol => Output
      @buffer = ""
    end

    def parse
      @root.parse(self)

      if @cursor == @input.size
        @output
      else
        raise NotEndOfInput.new(self)
      end
    end

    def any
      consume(1)
    end

    def repeat
      loop do
        @parent.not_nil!.parse(self)
      end
    rescue Interuption
    end

    def str(string)
      if next?(string)
        consume(string.size)
      else
        raise Str::NotFound.new(self, string: string)
      end
    end

    def consume(n)
      if @cursor + n <= @input.size
        @buffer += @input[@cursor...(@cursor + n)]
        @cursor += n
      else
        raise EndOfInput.new(self)
      end

      self
    end

    def aka(name)
      if @output.is_a?(String)
        @output = {} of Symbol => Output
      end

      @output.as(Hash(Symbol, Output))[name] = @buffer
      @buffer = ""

      self
    end

    def next?(string)
      @input[@cursor...(@cursor + string.size)] == string
    end

    def buffer?
      !!@buffer.presence
    end
  end
end
