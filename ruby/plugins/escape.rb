module Escape
  module_function

  def next_token!(stream, _, _)
    if stream.peek?(str: '\\')
      stream.next(amnt: 2) # this and the escaped char
      :retry
    end
  end
end