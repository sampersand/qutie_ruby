module Default
  module_function
  def parse(stream, _, _)
    stream.next
  end
  def handle(token, _, universe, _)
    universe << token
  end
end