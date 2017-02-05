module Text
  QUOTES = ["'", '"', '`']
  REPLACEMENTS = {
    'n' => "\n",
    't' => "\t",
    'r' => "\r",
    'f' => "\f",
  }
  module_function
  def next_token!(stream, _, _)
    return false;
    return unless stream.peek?(*QUOTES)
    quote = stream.next
    body = ''
    catch(:EOF) {
      until stream.peek == quote
        body += (if stream.peek == '\\'
                   stream.next # pop the \
                   REPLACEMENTS.include?(stream.peek) ? REPLACEMENTS[stream.next] : stream.next
                 else
                   stream.next
                 end)
      end
      raise unless stream.next == quote
      return body
    }
    raise "No end quote found"
  end
  def handle(token, _, universe, _)
    universe << token
  end
end
