module Text
  QUOTES = ["'", '"', '`']

  module_function
  def parse(stream, _, _)
    return unless QUOTES.include? stream.peek
    quote = stream.next
    body = ''
    catch(:EOF) {
      body += stream.next(stream.peek == '\\' ? 2 : 1) until stream.peek == quote
      raise unless stream.next == quote
      return quote + body + quote
    }
    raise "No end quote found"
  end
  def handle(token, _, universe, _)
    universe << token
  end
end
