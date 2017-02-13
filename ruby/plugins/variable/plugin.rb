require_relative 'variable'
require_relative '../regex/regex'
module Variable
  module_function
  
  VARIABLE_START = QT_Regex.new( /[a-z_$]/i )
  VARIABLE_CONT  = QT_Regex.new( /[a-z_0-9 ]/i )

  def next_token!(env)
    stream = env.stream
    return unless VARIABLE_START._match?(stream._peek(env), env)

    result = stream._next(env)
    catch(:EOF) do
      result = result.qt_add( stream._next(env), env ) while VARIABLE_CONT._match?( stream._peek(env), env )
      nil
    end
    QT_Variable.new( result.text_val.strip.to_sym )
  end

  def handle(token, env)
    env.universe << token
  end
end
