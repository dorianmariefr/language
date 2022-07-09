class Language
  class Parser
    property input : String
    property buffer : String
    property output : Output
    property root : Rule
    property rules : Array(Rule)
    property cursor : Int32

    @output : Output

    def initialize(
      @root : Rule,
      @rules : Array(Rule),
      @input : String,
      @cursor = 0,
      @buffer = "",
      @output = Output.new
    )
    end

    def merge(parser)
      @cursor = parser.cursor
      @buffer = parser.buffer
      @output.merge(parser.output)
    end

    def parse
      @root.parse(self)

      if @cursor == @input.size
        if @output == ""
          @buffer
        else
          @output
        end
      else
        raise NotEndOfInput.new(self)
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
      @buffer != ""
    end
  end
end
