module Whitespace
  require_relative '../regex/regex'
  
  WHITESPACE_REGEX = QT_Regex.new( /\s/ )

  module_function

  def next_token(env)
    stream = env.stream
    unless WHITESPACE_REGEX.qt_match(stream._peek(env), env)._rb_false?
      stream._next(env) # and ignore
      :retry
    end
  end
end