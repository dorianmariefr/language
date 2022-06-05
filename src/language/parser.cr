class Language
  class Parser
    class Interuption < Exception
    end

    class EndOfInput < Interuption
    end

    class NotEndOfInput < Exception
    end

    alias Output = String |
      Hash(Symbol, Output)

    def initialize(@root : Atom, @rules : Array(Atom), @input : String)
      @cursor = 0
      @size = @input.size
      @output = {} of Symbol => Output
      @buffer = ""
    end

    def parse
      @root.parse(self)
      if @cursor == @input.size
        @output
      else
        raise NotEndOfInput.new("cursor at #{@cursor}, input size #{@input.size}")
      end
    end

    def consume(n)
      if @cursor + n <= @size
        @buffer += @input[@cursor...(@cursor + n)]
        @cursor += n
      else
        raise EndOfInput.new("can't consume #{n} characters")
      end

      self
    end

    def aka(name)
      @output[name] = @buffer
      @buffer = ""

      self
    end

    def next?(string)
      @input[@cursor...(@cursor + string.size)] == string
    end
  end
end
