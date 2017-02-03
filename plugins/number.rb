# module Number
#   module_function
#   def parse_next_integer(stream)
#     num = ''
#     num += stream.next while !stream.empty? && stream.peek =~ /\d/
#     num
#   end

#   def parse(stream, tokens, parser)
#     return unless stream.peek =~ /\d/
#     num = parse_next_integer stream
#     tokens.push(if stream.peek == '.'
#                   num += stream.next + parse_next_integer(stream)
#                   num.to_f
#                 else
#                   num.to_i
#                 end)
#   end
# end

module Number
  module_function
  def next_token(stream, tokens, parser)
    num = ''
    num += stream.next while stream.peek =~ /\d/
    num.empty? ? nil : num
  rescue EOFError
    num.empty? ? nil : num
  end

end
















