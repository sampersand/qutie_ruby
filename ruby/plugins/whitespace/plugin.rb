module Whitespace
  module_function
  WHITESPACE_REGEX = /\s/
  def next_token!(stream:, **_)
    if stream.peek =~ WHITESPACE_REGEX
      stream.next # and ignore
      :retry
    end
  end
end