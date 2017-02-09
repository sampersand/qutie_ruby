module Number

  require_relative 'object'

  class QT_Number < QT_Object

    MATH_E = QT_Number.new(source: 'MATH_E', value: Math::E)
    MATH_PI = QT_Number.new(source: 'MATH_PI', value: Math::PI)
    ONE = QT_Number.new(source: '1', value: 1.0)
    ZERO = QT_Number.new(source: '0', value: 0)

    def self.from(source:)
      new(source: source, num_val: source.to_f)
    end

    def initialize(source:, num_val:)
      super(source: source)
      @num_val = num_val
    end
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