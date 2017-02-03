module Text
  QUOTES = ["'", '"', '`']
  REPLACEMENTS = { #
    /(?<![\\])\\n/ => "\n",
    /(?<![\\])\\t/ => "\t",
    /(?<![\\])\\r/ => "\r",
    /(?<![\\])\\f/ => "\f",
  }
  module_function
  def parse(stream, _, _)
    return unless QUOTES.include? stream.peek
    quote = stream.next
    body = ''
    catch(:EOF) {
      body += stream.next(stream.peek == '\\' ? 2 : 1) until stream.peek == quote
      raise unless stream.next == quote
      REPLACEMENTS.each{ |k, v| body.gsub!(k, v) }
      return body
    }
    raise "No end quote found"
  end
  def handle(token, _, universe, _)
    universe << token
  end
end
