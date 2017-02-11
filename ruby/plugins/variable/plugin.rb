require_relative 'variable'
require_relative '../regex/regex'
module Variable
  module_function
  
  VARIABLE_START = QT_Regex.new( /[a-z_]/i )
  VARIABLE_CONT  = QT_Regex.new( /[a-z_0-9]/i )

  def next_token!(stream:, universe:, parser:, **_)
    return if stream._peek.qt_rgx(VARIABLE_START)._nil?

    result = stream._next
    catch(:EOF) do
      result = result.qt_add( stream._next ) until stream._peek.qt_rgx( VARIABLE_CONT )._nil?
      nil
    end
    QT_Variable::from(source: result)
  end

  def handle(token:, universe:, **_)
    universe << token
  end
end
