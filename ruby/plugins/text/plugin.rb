require_relative 'text'
module Text
  QUOTES = ["'", '"', '`']
  
  REPLACEMENTS = {
    'n' => "\n",
    't' => "\t",
    'r' => "\r",
    'f' => "\f",
  }
  
  module_function

  def next_token!(stream:, **_)
    return unless stream.peek_any?(vals: QUOTES)
    quote = stream.next
    body = quote

    catch(:EOF) {
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
