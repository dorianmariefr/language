class Language
  class Output
    def_clone

    alias Type = String | Hash(Symbol, Output)

    getter raw : Type

    def initialize(@raw : Type = "")
    end

    def []=(key, value)
      case @raw
      when String
        @raw = { key => value }
      when Hash(Symbol, Output)
        @raw.as(Hash(Symbol, Output))[key] = value
      end
    end

    def merge(other)
      if other.raw.is_a?(Hash(Symbol, Output))
        if @raw.is_a?(String)
          @raw = {} of Symbol => Output
        end

        other.raw.as(Hash(Symbol, Output)).each do |key, value|
          @raw.as(Hash(Symbol, Output))[key] = value
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
