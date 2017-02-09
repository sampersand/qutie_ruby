module Constants
  module_function
  CONSTANTS = {
    true: true,
    false: false,
    nil: nil,
    null: nil,
    none: nil
  }

  # def next_token!(stream, _, _)
  #   res = BOOELEANS.find{ |_, sym| stream.peek?(sym) }
  #   res and stream.next!(res[-1])
  # end

  # def handle(token, stream, universe, parser)
  #   universe << (case token.downcase
  #                when BOOELEANS[:true] then true
  #                when BOOELEANS[:false] then false
  #                when BOOELEANS[:nil], BOOELEANS[:null], BOOELEANS[:none] then nil
  #                else raise "Unknown boolean `#{token}`"
  #                end)
  # end

end













p = 7
q = 19
n = p * q
e = 5

n2 = 3;
d = (1 + n2 * (p-1) * (q-1)) / e



# n = 133
# e = 5
# n =133
# d = 65
P = 10
C = P ** e % n
puts C ** d % n
puts (132 ** e) ** d % n















