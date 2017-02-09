module Variable
  require_relative 'object'
  class QT_Variable < QT_Object
    def initialize(source:)
      super
      @value = source.to_sym
    end
  end

  module_function
  
  VARIABLE_START = /[a-z_]/i
  VARIABLE_CONT  = /[a-z_0-9]/i
  def next_token!(stream, universe, parser)
    return stream.next if stream.peek?(str: '$') # this is bad!
    return unless stream.peek =~ VARIABLE_START
    result = ''
    parser.catch_EOF(universe) {
      result += stream.next while stream.peek =~ VARIABLE_CONT
      nil
    }
    result
  end

  def handle(token, stream, universe, _)
    universe << QT_Variable.new(source: token)
  end
end