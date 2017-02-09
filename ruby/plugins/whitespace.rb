module Whitespace
  module_function
  WHITESPACE_REGEX = /\s/
  def next_token!(stream, _, _)
    if stream.peek?(WHITESPACE_REGEX, len: 1)
      stream.next(amnt: 1) # and ignore
      :retry
    end
  end
end