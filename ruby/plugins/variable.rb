require_relative 'object'
module Variable
  class QT_Variable < QT_Object

    def self.from(source:)
      new(value: source.to_sym )
    end
    
    def initialize(value:)
      @value = value
    end

    def to_s
      @value.to_s
    end

    # qt methods
      # conversion
        def qt_to_text
          Text::QT_Text.new(text_val: to_s)
        end

  end

  module_function
  
  VARIABLE_START = /[a-z_]/i
  VARIABLE_CONT  = /[a-z_0-9]/i
  def next_token!(stream:, universe:, parser:, **_)
    return stream.next if stream.peek?(str: '$') # this is bad!
    return unless stream.peek =~ VARIABLE_START
    result = ''
    parser.catch_EOF(universe) {
      result += stream.next while stream.peek =~ VARIABLE_CONT
      nil
    }
    result
  end

  def handle(token:, universe:, **_)
    universe << QT_Variable::from(source: token)
  end
end