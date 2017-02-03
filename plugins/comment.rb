module Comment
  module_function

  def parse_one_line(stream, tokens, parser)
    return unless stream.peek == '#' || stream.peek(2) == '//'
    until stream.next == "\n"; end
    true
  end
  def parse_multi_line(stream, tokens, parser)
  end

  def parse(stream, tokens, parser)
    (parse_one_line(stream, tokens, parser) || parse_multi_line(stream, tokens, parser)) && :retry
  end
end
