module Whitespace
  module_function
  def next_token!(stream, _, _)
    if stream.peek =~ /\s/
      stream.next # and ignore
      :retry
    end
  end
end