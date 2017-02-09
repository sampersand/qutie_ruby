module Default
  module_function
  def next_token!(stream, _, _)
    stream.next(amnt: 1)
  end
  def handle(token, _, universe, _)
    universe << token
  end
end