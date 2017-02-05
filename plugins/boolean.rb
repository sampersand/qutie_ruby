module Boolean
  module_function
  BOOELEANS = {
    true: 'true',
    false: 'false',
    nil: 'nil',
    null: 'null',
    none: 'none'
  }

  def next_token!(stream, _, _)
    res = BOOELEANS.find{ |_, sym| stream.peek?(sym) }
    res and stream.next!(res[-1].length)
  end

  def handle(token, stream, universe, parser)
    universe << (case token.downcase
                 when BOOELEANS[:true] then true
                 when BOOELEANS[:false] then false
                 when BOOELEANS[:nil], BOOELEANS[:null], BOOELEANS[:none] then nil
                 else raise "Unknown boolean `#{token}`"
                 end)
  end

end
