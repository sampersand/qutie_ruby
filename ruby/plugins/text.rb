require_relative 'object'
module Text

  class QT_Text < QT_Object

    attr_reader :text_val
    def self.from(source:)
      # new(body: source[1...-1], quotes: [source[0], source[-1]])
      new(text_val: source[1...-1])
    end

    def initialize(text_val:)
      @text_val = text_val
    end

    def to_s
      if @text_val =~ /(?<!\\)'/
        if @text_val =~ /(?<!\\)"/
          if @text_val =~ /(?<!\\)`/
            "`#{@text_val.gsub(/(?<!\\)`/, '\\\\`')}`"
          else
            "`#{@text_val}`"
          end
        else 
          "\"#{@text_val}\""
        end
      else 
        "'#{@text_val}'"
      end
    end

    # qt methods
      # conversion
        def qt_to_text
          self
        end

      # operators
        # math
          def qt_add(right:)
            right = right.qt_to_text or return
            QT_Text.new(text_val: @text_val + right.text_val)
          end

          def qt_add_r(left:)
            left = left.qt_to_text or return
            QT_Text.new(text_val: left.text_val + @text_val)
          end
  end

  QUOTES = ["'", '"', '`']
  REPLACEMENTS = {
    'n' => "\n",
    't' => "\t",
    'r' => "\r",
    'f' => "\f",
  }
  module_function
  def next_token!(stream:, universe:, parser:, **_)
    return unless stream.peek_any?(vals: QUOTES)
    quote = stream.next
    body = quote

    parser.catch_EOF(universe) {
      until stream.peek?(str: quote)
        if stream.peek?(str: '\\')
           stream.next # pop the \
           to_find = stream.next
           body += REPLACEMENTS.fetch(to_find, to_find)
        else
           body += stream.next
        end
      end
      fail unless stream.peek?(str: quote)
      body += stream.next(amnt: quote.length)
      nil
    }
    body

  end

  def handle(token:, universe:, **_)
    universe << QT_Text::from(source: token)
  end
end
