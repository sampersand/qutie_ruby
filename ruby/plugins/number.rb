module Number

  require_relative 'object'

  class QT_Number < QT_Object
    def self.from(source:)
      new(source: source, num_val: source.to_f)
    end

    def initialize(source:, num_val:)
      super(source: source)
      @num_val = num_val
    end


    MATH_E = QT_Number.new(source: 'MATH_E', num_val: Math::E)
    MATH_PI = QT_Number.new(source: 'MATH_PI', num_val: Math::PI)
    ONE = QT_Number.new(source: '1', num_val: 1.0)
    ZERO = QT_Number.new(source: '0', num_val: 0)

  end

  module_function

  def next_token!(stream:, universe:, parser:, **_)
    return unless stream.peek =~ /\d/
    num = ''
    parser.catch_EOF(universe) {
      num += stream.next while stream.peek =~ /\d/
      if stream.peek?(str: '.')
        num += stream.next
        num += stream.next while stream.peek =~ /\d/
      end
      nil
    }
    num
  end

  def handle(token:, universe:, **_)
    universe << QT_Number::from(source: token)
  end

end