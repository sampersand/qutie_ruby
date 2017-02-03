module Text
  QUOTES = ["'", '"', '`']

  module_function
  def parse(stream, _, _)
    return unless QUOTES.include? stream.peek
    quote = stream.next
    body = ''
    body += stream.next(stream.peek == '\\' ? 2 : 1) until stream.peek == quote
    raise unless stream.next == quote
    body
  end
  def handle(token, _, universe, _)
    universe << token

  end
end
