require_relative 'variable'
require_relative '../regex/regex'
module Variable
  module_function
  
  VARIABLE_START = QT_Regex.new( /[a-z_$]/i )
  VARIABLE_CONT  = QT_Regex.new( /[a-z_0-9 ]/i )

  def next_token!(environment)
    stream = environment.stream
    return if stream._peek.qt_rgx(VARIABLE_START)._nil?

    result = stream._next
    catch(:EOF) do
      result = result.qt_add( stream._next ) until stream._peek.qt_rgx( VARIABLE_CONT )._nil?
      nil
    end
    # QT_Variable::from(source: result)
    QT_Variable.new( result.text_val.strip.to_sym )
  end

  def handle(token, environment)
    environment.universe << token
  end
end
