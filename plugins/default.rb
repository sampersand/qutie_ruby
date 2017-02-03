module Default
  module_function
  def parse(stream, tokens, parser)
    tokens.push stream.next
    true
  end
end