module Text
  require_relative 'object'
  class QT_Text < QT_Object
    def initialize(source:, parens:)
      super(source: source)
      @parens = parens
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
  def next_token!(stream, universe, parser)
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

  def handle(token, _, universe, _)
    puts token
    exit
    universe << QT_Text::from(source: token)
  end
end
