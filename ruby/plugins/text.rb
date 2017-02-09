require_relative 'object'
module Text

  class QT_Text < QT_Object

    def self.from(source:)
      new(body: source[1...-1], quotes: [source[0], source[-1]])
    end

    def initialize(body:, quotes:)
      @body = body
      @quotes = quotes
    end

    def to_s
      "#{@quotes[0]}#{@body}#{@quotes[1]}"
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
