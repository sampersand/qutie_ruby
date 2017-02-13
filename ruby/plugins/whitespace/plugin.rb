module Whitespace
  require_relative '../regex/regex'
  
  WHITESPACE_REGEX = QT_Regex.new( /\s/ )

  module_function

  def next_token!(environment)
    stream = environment.stream
    if WHITESPACE_REGEX =~ stream._peek
      stream._next # and ignore
      :retry
    end
  end
end