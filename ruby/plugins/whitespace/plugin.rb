module Whitespace
  require_relative '../regex/regex'
  
  WHITESPACE_REGEX = QT_Regex.new(/\s/)

  module_function

  def next_token!(stream:, **_)
    if stream.qt_peek(QT_Number::ONE).qt_regex_match(WHITESPACE_REGEX).true?
      stream.qt_next(QT_Number::ONE) # and ignore
      :retry
    end
  end
end