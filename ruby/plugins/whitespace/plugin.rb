module Whitespace
  module_function
  WHITESPACE_REGEX = /\s/
  def next_token!(stream:, **_)
    if stream.qt_peek(amnt: QT_Number::ONE) =~ WHITESPACE_REGEX
      stream.qt_next(amnt: QT_Number::ONE) # and ignore
      :retry
    end
  end
end