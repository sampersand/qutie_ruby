module Comment
  module_function

  def parse_single(stream)
    return unless stream.peek == '#' || stream.peek(2) == '//'
    stream.next until stream.peek == "\n"
    :retry
  end
  def parse_multi(stream)
    return unless stream.peek(2) == '/*'
    stream.next until stream.peek(2) == "*/" # this will fail inside strings, but that's ok C does as well.
    :retry
  end

  def parse(stream, _, _)
    parse_single(stream) || parse_multi(stream)
  end
end
