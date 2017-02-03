module Variable
  module_function
  
  def parse(stream, _, _)
    return unless stream.peek =~ /[a-zA-Z_]/
    result = ''
    catch(:EOF) {
      result += stream.next while stream.peek =~ /[a-zA-Z_0-9]/
    }
    result
  end

  def handle(token, stream, universe, _)
    universe << token.to_sym
  end
end
