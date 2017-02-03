module Boolean
  module_function
  BOOELEANS = {
    true: 'true',
    false: 'false',
    nil: 'null'
  }

  def parse(stream, _, _)
    res = BOOELEANS.find{ |_, sym| sym == stream.peek(sym.length) && stream.next(sym.length) }
    res and res[-1]
  end

  def handle(token, stream, universe, parser)
    universe << (case token.downcase
                 when BOOELEANS[:true] then true
                 when BOOELEANS[:false] then false
                 when BOOELEANS[:nil] then nil
                 else raise "Unknown boolean `#{token}`"
                 end)
  end

end
