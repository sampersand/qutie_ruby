module Variable
  module_function
  
  VARIABLE_START = /[a-zA-Z_]/
  VARIABLE_CONT  = /[a-zA-Z_]/
  def next_token!(stream, _, _) 
    return unless stream.peek?(VARIABLE_START, len: 1)
    result = ''
    catch(:EOF) {
      result += stream.next!(1) while stream.peek?(VARIABLE_CONT, len: 1)
    }
    result
  end

  def handle(token, stream, universe, _)
    universe << token.to_sym
  end
end