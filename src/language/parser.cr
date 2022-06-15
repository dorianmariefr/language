class Language
  class Parser
    def_clone

    getter input : String
    getter buffer : String
    getter output : Output
    property root : Rule
    property cursor : Int32

    @output : Output

    def initialize(@root : Rule, @rules : Array(Rule), @input : String, @cursor = 0)
      @output = Output.new
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
    end

    def aka(name)
      if @buffer.empty?
        @output = Output.new({name => @output})
      else
        @output[name] = Output.new(@buffer)
        @buffer = ""
      end
    end

    def next?(string)
      @input[@cursor...(@cursor + string.size)] == string
    end

    def buffer?
      !!@buffer.presence
    end
  end
end
