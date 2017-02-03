module Escape
  module_function

  def parse(stream, _, _)
    if stream.peek =~ /\\/
      stream.next(2) # this and the escaped char
    end
  end
  def handle(token, _, universe, _ )
    universe << token[1]
  end

end