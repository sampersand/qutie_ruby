require_relative 'variable'
require_relative '../regex/regex'
module Variable
  module_function
  
  VARIABLE_START = QT_Regex.new(regex_val: /[a-z_]/i)
  VARIABLE_CONT  = QT_Regex.new(regex_val: /[a-z_0-9]/i)

  def next_token!(stream:, universe:, parser:, **_)
    return unless stream.qt_peek(amnt: QT_Number::ONE).qt_rgx(right: VARIABLE_START)
    result = ''
    catch(:EOF) {
      result += stream.next while stream.peek =~ VARIABLE_CONT
      nil
    }
    result
  end

  def handle(token:, universe:, **_)
    universe << QT_Variable::from(source: token)
  end
end