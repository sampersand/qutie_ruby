module Whitespace
  require_relative '../regex/regex'
  
  WHITESPACE_REGEX = QT_Regex.new( /\s/ )

  module_function

  def next_token!(stream:, **_)

    unless stream.qt_peek(QT_Number::ONE).qt_rgx(WHITESPACE_REGEX).qt_nil?
      stream.qt_next(QT_Number::ONE) # and ignore

      :retry
    end
  end
end