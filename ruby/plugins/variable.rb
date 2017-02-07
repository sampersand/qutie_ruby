module Variable
  module_function
  
  VARIABLE_START = /[a-zA-Z_]/
  VARIABLE_CONT  = /[a-zA-Z_]/
  def next_token!(stream, universe, parser)
    return stream.next! if stream.peek?('$')
    return unless stream.peek?(VARIABLE_START, len: 1)
    result = ''
    parser.catch_EOF(universe) {
      result += stream.next!(1) while stream.peek?(VARIABLE_CONT, len: 1)
      nil
    }
    result
  end

  def handle(token, stream, universe, _)
    universe << token.to_sym
  end
end