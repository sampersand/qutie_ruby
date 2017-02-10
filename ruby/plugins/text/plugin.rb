require_relative 'text'
module Text
  QUOTES = ["'", '"', '`']
  EXCAPE_CHAR = '\\'
  REPLACEMENTS = {
    'n' => "\n",
    't' => "\t",
    'r' => "\r",
    'f' => "\f",
  }
  
  module_function

  def escape(stream:)
    case (chr=stream.next)
    when 'n' then "\n"
    when 't' then "\t"
    when 'r' then "\r"
    when 'f' then "\f"
    when 'u' then stream.next(amnt: 4).to_i(16).chr(Encoding::UTF_8)
    when 'U' then stream.next(amnt: 8).to_i(16).chr(Encoding::UTF_16)
    else chr
    end
  end
  def next_token!(stream:, **_)
    return unless stream.peek_any?(vals: QUOTES) # if quotes change length this will break
    quote = stream.next # if quotes change length this will break
    body = quote

    catch(:EOF) {
      until stream.peek?(str: quote)
        if stream.peek?(str: EXCAPE_CHAR)
          stream.next(amnt: EXCAPE_CHAR.length) # pop the \
          body += escape(stream: stream)
        else
          body += stream.next
        end
      end
      fail unless stream.peek?(str: quote)
      body += stream.next(amnt: quote.length)
      true
    } or fail "Reach EOF before finishing string starting with: #{quote}"
    body

  end

  def handle(token:, universe:, **_)
    universe << QT_Text::from(source: token)
  end
end
