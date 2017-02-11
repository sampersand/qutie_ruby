require_relative 'variable'
require_relative '../regex/regex'
module Variable
  module_function
  
  VARIABLE_START = QT_Regex.new( /[a-z_]/i )
  VARIABLE_CONT  = QT_Regex.new( /[a-z_0-9]/i )

  def next_token!(stream:, universe:, parser:, **_)
    return if stream.qt_peek(QT_Number::ONE).qt_rgx(VARIABLE_START) == QT_Null::INSTANCE

    result = stream.qt_next(QT_Number::ONE).text_val
    catch(:EOF) {
      result += stream.qt_next(QT_Number::ONE).text_val until stream.qt_peek(QT_Number::ONE).qt_rgx( VARIABLE_CONT ) == QT_Null::INSTANCE
      nil
    }
    result
  end

  def handle(token:, universe:, **_)
    universe << QT_Variable::from(source: token)
  end
end
