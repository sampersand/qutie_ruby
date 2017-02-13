module Whitespace
  require_relative '../regex/regex'
  
  WHITESPACE_REGEX = QT_Regex.new( /\s/ )

  module_function

  def next_token!(env)
    stream = env.stream
    if WHITESPACE_REGEX.qt_match(stream._peek, env)._bool
      stream._next # and ignore
      :retry
    end
  end
end