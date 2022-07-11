class Language
  class Parser
    class Interuption < Exception
      def initialize(@parser : Parser, @atom : Atom? = Atom.new)
      end

      def message
        "#{input}\n#{" " * cursor}^\n#{@atom.inspect}"
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
  end
end
