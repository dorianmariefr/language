class Language
  class Output
    def_clone

    alias Type = String | Array(Output) | Hash(Symbol, Output)

    getter raw : Type

    def initialize(@raw : Type = "")
    end

    def []=(key : Symbol, value : Output)
      case @raw
      when String
        @raw = { key => value }
      when Array(Output)
        @raw.as(Array(Output)) << Output.new({ key => value })
      when Hash(Symbol, Output)
        @raw.as(Hash(Symbol, Output))[key] = value
      end
    end

    def merge(other : Output)
      case @raw
      when String
        case other.raw
        when String
          @raw = @raw.as(String) + other.raw.as(String)
        when Array(Output)
          @raw = other.raw
        when Hash(Symbol, Output)
          @raw = other.raw
        end
      when Array(Output)
        case other.raw
        when String
          return
        when Array(Output)
          @raw = other.raw
        when Hash(Symbol, Output)
          @raw.as(Array(Output)) << other
        end
      when Hash(Symbol, Output)
        case other.raw
        when String
          return
        when Array(Output)
          return
        when Hash(Symbol, Output)
          @raw.as(Hash(Symbol, Output)).merge!(other.raw.as(Hash(Symbol, Output)))
        end
      end
    end

    def <<(other)
      case @raw
      when String
        case other.raw
        when String
          @raw = @raw.as(String) + other.raw.as(String)
        when Array(Output)
          @raw = other.raw
        when Hash(Symbol, Output)
          @raw = [other]
        end
      when Array(Output)
        case other.raw
        when String
          @raw.as(Array(Output)) << other
        when Array(Output)
          @raw = @raw.as(Array(Output)) + other.raw.as(Array(Output))
        when Hash(Symbol, Output)
          @raw.as(Array(Output)) << other
        end
      when Hash(Symbol, Output)
        case other.raw
        when String
          return
        when Array(Output)
          return
        when Hash(Symbol, Output)
          @raw.as(Hash(Symbol, Output)).merge!(other.raw.as(Hash(Symbol, Output)))
        end
      end
    end

    def ==(other : Output)
      raw == other.raw
    end

    def ==(other)
      raw == other
    end

    def pretty_print(pp)
      raw.pretty_print(pp)
    end

    def to_s(io)
      raw.to_s(io)
    end

    def inspect(io)
      raw.inspect(io)
    end
  end
end

class Object
  def ===(other : Language::Output)
    self === other.raw
  end
end

struct Value
  def ==(other : Language::Output)
    self == other.raw
  end
end

class Reference
  def ==(other : Language::Output)
    self == other.raw
  end
end

class Array
  def ==(other : Language::Output)
    self == other.raw
  end
end

class Hash
  def ==(other : Language::Output)
    self == other.raw
  end
end

class Regex
  def ===(other : Language::Output)
    value = self === other.raw
    $~ = $~
    value
  end
end
