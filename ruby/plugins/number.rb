require_relative 'object'
module Number

  class QT_Number < QT_Object
    attr_reader :num_val

    def self.from(source:)
      new(num_val: source.to_f)
    end

    def initialize( num_val:)
      @num_val = num_val
    end

    def to_s
      @num_val.to_s
    end

    # consts
      E    = QT_Number.new(num_val: Math::E)
      PI   = QT_Number.new(num_val: Math::PI)
      ONE  = QT_Number.new(num_val: 1.0)
      ZERO = QT_Number.new(num_val: 0)

    # qt methods
      # conversion
        def qt_to_num
          self
        end

      # operators
        # math
          private
            def numer_func(right:, meth:)
              right = right.qt_to_num or return
              QT_Number.new(num_val: @num_val.method(meth).call(right.num_val))
            end
            def numer_func_r(left:, meth:)
              left = left.qt_to_num or return
              QT_Number.new(num_val: left.num_val.method(meth).call(@num_val) )
            end

          public
            def qt_add(right:) numer_func(right: right, meth: :+) end
            def qt_sub(right:) numer_func(right: right, meth: :-) end
            def qt_mul(right:) numer_func(right: right, meth: :*) end
            def qt_div(right:) numer_func(right: right, meth: :/) end
            def qt_mod(right:) numer_func(right: right, meth: :%) end

            def qt_pow(right:) numer_func(right: right, meth: :**) end
            def qt_add_r(left:) numer_func_r(left: left, meth: :+) end
            def qt_sub_r(left:) numer_func_r(left: left, meth: :-) end
            def qt_mul_r(left:) numer_func_r(left: left, meth: :*) end
            def qt_div_r(left:) numer_func_r(left: left, meth: :/) end
            def qt_mod_r(left:) numer_func_r(left: left, meth: :%) end
            def qt_pow_r(left:) numer_func_r(left: left, meth: :**) end
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