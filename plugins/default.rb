module Default
  module_function
  def next_token!(stream, _, _)
    stream.next
  end
  def handle(token, _, universe, _)
    universe << token
  end
end