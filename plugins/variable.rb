module Variable
  module_function
  def parse(stream, tokens, parser)
    return unless stream.peek =~ /[a-zA-Z_]/
    result = ''
    result += stream.next while !stream.empty? && stream.peek =~ /[a-zA-Z_0-9]/
    tokens.push result
    true
  end
end
