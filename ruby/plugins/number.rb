require_relative 'object'
module Number
  class QT_Number < QT_Object
    attr_reader :num_val
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

    # qt methods
      def qt_add(right:)
        QT_Number.new(source: nil, num_val: @num_val + right.qt_to_num.num_val)
      end
      def qt_add_r(left:)
        QT_Number.new(source: nil, num_val: left.qt_to_num.num_val + @num_val)
      end
      def qt_to_num; self end
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