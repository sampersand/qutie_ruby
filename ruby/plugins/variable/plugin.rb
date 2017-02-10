require_relative 'variable'
module Variable
  module_function
  
  VARIABLE_START = /[a-z_]/i
  VARIABLE_CONT  = /[a-z_0-9]/i
  def next_token!(stream:, universe:, parser:, **_)
    return stream.next if stream.peek?(str: '$') # this is bad!
    return unless stream.peek =~ VARIABLE_START
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