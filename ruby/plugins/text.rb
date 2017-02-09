module Text
  QUOTES = ["'", '"', '`']
  REPLACEMENTS = {
    'n' => "\n",
    't' => "\t",
    'r' => "\r",
    'f' => "\f",
  }
  module_function
  def next_token!(stream, universe, parser)
    return unless stream.peek?(*QUOTES)
    quote = stream.next!(1)
    body = ''

    parser.catch_EOF(universe) {
      until stream.peek?(quote)
        body += (if stream.peek?('\\')
                    stream.next!(1) # pop the \
                    to_find = stream.next!(1)
                    REPLACEMENTS.fetch(to_find, to_find)
                 else
                    stream.next!(1)
                 end)
      end
      raise unless stream.peek?(quote)
      stream.next!(quote)
      nil
    }
    body

  end

  def handle(token, _, universe, _)
    universe << token
  end
end
