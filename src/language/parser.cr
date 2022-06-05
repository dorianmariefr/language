class Language
  class Parser
    class Interuption < Exception
    end

    class EndOfInput < Interuption
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
      @output
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
  end
end
