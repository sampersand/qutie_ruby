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
  end

  module_function

  def next_token!(stream, universe, parser)
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

  def handle(token, _, universe, _)
    universe << QT_Number::from(source: token)
  end

end