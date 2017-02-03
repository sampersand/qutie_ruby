module Text
  QUOTES = ["'", '"', '`']

  module_function
  def parse(stream, tokens, parser)
    return unless QUOTES.include? stream.peek

    start_quote = stream.next
    body = ''

    body += stream.next(stream.peek == '\\' ? 2 : 1) until stream.peek == start_quote

    tokens.push start_quote + body + stream.next

    true
  end
end
