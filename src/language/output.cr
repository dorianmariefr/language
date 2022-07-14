require "colorize"

class Language
  class Output
    alias Type = Nil | String | Array(Output) | Hash(Symbol, Output)

    getter raw : Type

    def initialize(@raw : Type = nil)
    end

    def clone
      Output.new(@raw.clone)
    end

    def present?
      @raw != nil
    end

    def is_nil?
      @raw.is_a?(Nil)
    end

    def as_nil
      @raw.as(Nil)
    end

    def is_string?
      @raw.is_a?(String)
    end

    def as_s : String
      @raw.as(String)
    end

    def is_array?
      @raw.is_a?(Array(Output))
    end

    def as_a : Array(Output)
      @raw.as(Array(Output))
    end

    def is_hash?
      @raw.is_a?(Hash(Symbol, Output))
    end

    def as_h : Hash(Symbol, Output)
      @raw.as(Hash(Symbol, Output))
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

    def []=(key : Symbol, value : Output)
      if ENV.fetch("DEBUG", nil)
        puts "[]=".colorize(:cyan)
        pp self
        pp key
        pp value
      end

      case @raw
      when Nil
        @raw = {key => value}
      when String
        @raw = {key => value}
      when Array(Output)
        @raw.as(Array(Output)) << Output.new({key => value})
      when Hash(Symbol, Output)
        @raw.as(Hash(Symbol, Output))[key] = value
      end
    end

    def merge(other : Output)
      if ENV.fetch("DEBUG", nil)
        puts "merge".colorize(:cyan)
        pp self
        pp other
      end

      case @raw
      when Nil
        @raw = other.raw
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

    def <<(other)
      if ENV.fetch("DEBUG", nil)
        puts "<<".colorize(:cyan)
        pp self
        pp other
      end

      case @raw
      when Nil
        case other.raw
        when String
          @raw = [other]
        when Array(Output)
          @raw = [other]
        when Hash(Symbol, Output)
          @raw = [other]
        end
      when String
        case other.raw
        when String
          @raw = @raw.as(String) + other.raw.as(String)
        when Array(Output)
          @raw = [other]
        when Hash(Symbol, Output)
          @raw = [other]
        end
      when Array(Output)
        @raw.as(Array(Output)) << other
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
