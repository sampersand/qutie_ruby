module Number
  module_function

  def parse(stream, _, _)
    return unless stream.peek =~ /\d/
    num = ''
    num += stream.next while stream.peek =~ /\d/
    num
  end

  def handle(token, _, universe, _)
    universe << token.to_i
  end

end





















