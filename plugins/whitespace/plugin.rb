module Whitespace

  require 'plugins/regex/regex'
  assert defined? QT_Regex, "QT_Regex isn't defined inside Whitespace"

  WHITESPACE_REGEX = QT_Regex.new( /\s/ )
  assert_is_a(WHITESPACE_REGEX, QT_Regex, "#{name}::WHITESPACE_REGEX")
  module_function

  def next_token(env)
    assert_is_a(env, Environment, 'env')
    stream = env.s
    assert_is_a(stream, QT_Universe, 'env.stream')

    assert_is_a(WHITESPACE_REGEX, QT_Regex, "#{name}::WHITESPACE_REGEX")
    unless WHITESPACE_REGEX.qt_match(stream._peek(env), env)._rb_false?
      stream._next(env) # and ignore
      :retry
    end
  end
end

