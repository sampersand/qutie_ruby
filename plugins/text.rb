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
    return unless stream.peek?(*QUOTES)
    quote = stream.next!(1)
    body = ''
    catch(:EOF) {
      until stream.peek?(quote)
        body += (if stream.peek?('\\')
                    stream.next!(1) # pop the \
                    to_find = stream.next!
                    REPLACEMENTS.fetch(to_find, to_find)
                 else
                    stream.next!
                 end)
      end
      raise unless stream.peek?(quote)
      stream.next!(quote.length)
      return body
    }
    raise "No end quote found"
  end

  def handle(token, _, universe, _)
    universe << token
  end
end
