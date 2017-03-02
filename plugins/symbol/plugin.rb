module Symbols
  require 'plugins/regex/regex'
  assert defined? QT_Regex, "QT_Regex wasn't imported properly"

  require_relative 'symbol'
  assert defined? QT_Symbol, "QT_Symbol wasn't imported properly"

  SYMBOL_START = QT_Regex.new( /[a-z_$]/i )
  SYMBOL_CONT  = QT_Regex.new( /[a-z_0-9]/i )
  assert_is_a(SYMBOL_START, QT_Regex, "#{name}::SYMBOL_START")
  assert_is_a(SYMBOL_CONT, QT_Regex, "#{name}::SYMBOL_CONT")

  module_function
  def next_token(env)
    assert_is_a(env, Environment, 'env')
    stream = env.stream
    assert_is_a(stream, QT_Universe, 'env.stream')
    return unless SYMBOL_START._match?(stream._peek(env), env)
    result = stream._next(env)
    assert_is_a(result, QT_Default, 'result (aka stream._next)')
    catch(:EOF) do
      result = result.qt_add( stream._next(env), env ) while SYMBOL_CONT._match?( stream._peek(env), env )
      assert_is_a(result, QT_Default, 'result (from stream.qt_add)')
      nil
    end
    result = QT_Default.new( result.text_val.strip.to_sym )
    res = QT_Symbol::from( result, env )
    assert_is_a(res, QT_Symbol, 'QT_Symbol::from')
    res
  end

  def handle(token, env)
    env.universe << token
  end
end









