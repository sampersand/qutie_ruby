class QT_Number < QT_Object
  attr_reader :num_val

  def self.from(source:)
    new(num_val: source.to_f)
  end

  def initialize( num_val:)
    @num_val = num_val
  end

  def to_s
    is_int = @num_val == @num_val.to_i rescue false
    is_int ? @num_val.to_i.to_s : @num_val.to_s
  end

  def ==(other)
    other.is_a?(QT_Number) && @num_val == other.num_val
  end

  def hash
    @num_val
  end

  # consts
    E    = QT_Number.new(num_val: Math::E)
    PI   = QT_Number.new(num_val: Math::PI)
    ONE  = QT_Number.new(num_val: 1.0)
    NaN  = QT_Number.new(num_val: Float::NAN)
    ZERO = QT_Number.new(num_val: 0)

  # qt methods
    # conversion
      def qt_to_num
        self
      end
      def qt_to_bool
        QT_Boolean::get(@num_val != 0)
      end

    # operators
        private
          def numer_func(right:, lmeth:)
            right = right.qt_to_num or return
            QT_Number.new(num_val: @num_val.method(lmeth).call(right.num_val))
          end
          def numer_func_r(left:, lmeth:)
            left = left.qt_to_num or return
            QT_Number.new(num_val: left.num_val.method(lmeth).call(@num_val) )
          end

        public
        # math
          def qt_cmp(right:) numer_func(right: right, lmeth: :<=>) end

          def qt_add(right:) numer_func(right: right, lmeth: :+) end
          def qt_sub(right:) numer_func(right: right, lmeth: :-) end
          def qt_mul(right:) numer_func(right: right, lmeth: :*) end
          def qt_div(right:) numer_func(right: right, lmeth: :/) end
          def qt_mod(right:) numer_func(right: right, lmeth: :%) end
          def qt_pow(right:) numer_func(right: right, lmeth: :**) end
          def qt_add_r(left:) numer_func_r(left: left, lmeth: :+) end
          def qt_sub_r(left:) numer_func_r(left: left, lmeth: :-) end
          def qt_mul_r(left:) numer_func_r(left: left, lmeth: :*) end
          def qt_div_r(left:) numer_func_r(left: left, lmeth: :/) end
          def qt_mod_r(left:) numer_func_r(left: left, lmeth: :%) end
          def qt_pow_r(left:) numer_func_r(left: left, lmeth: :**) end
end

