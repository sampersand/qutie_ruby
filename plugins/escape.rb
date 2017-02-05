module Escape
  module_function

  def next_token!(stream, _, _)
    if stream.peek?('\\')
      stream.next!(2) # this and the escaped char
      :retry
    end
  end
end