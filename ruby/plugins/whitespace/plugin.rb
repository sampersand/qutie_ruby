module Whitespace
  require_relative '../regex/regex'
  
  WHITESPACE_REGEX = QT_Regex.new( /\s/ )

  module_function

  def next_token!(stream:, **_)
    unless stream._peek.qt_rgx(WHITESPACE_REGEX).qt_nil?
      stream._next # and ignore
      :retry
    end
  end
end