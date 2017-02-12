class QT_Number < QT_Object
  attr_reader :num_val

  def self.from(source, base: nil)
    fail "Bad source type `#{source.class}`" unless source.is_a?(QT_Default)
    if base
      new(source.source_val.to_s.to_i(base.num_val).to_f )
    else
      new(source.source_val.to_s.to_f)
    end
  end

  def initialize(num_val)
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
    NEG_1 = QT_Number.new( -1         )
    ZERO  = QT_Number.new(  0         )
    ONE   = QT_Number.new(  1         )
    TWO   = QT_Number.new(  2         )

    E     = QT_Number.new( Math::E    )
    PI    = QT_Number.new( Math::PI   )
    NaN   = QT_Number.new( Float::NAN )

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
          def numer_func_l(right, lmeth)
            right = right.qt_to_num 
            return right if right == QT_Missing::INSTANCE 
            QT_Number.new(@num_val.method(lmeth).call(right.num_val))
          end
          def numer_func_r(left, lmeth)
            left = left.qt_to_num 
            return left if left == QT_Missing::INSTANCE 
            QT_Number.new(left.num_val.method(lmeth).call(@num_val) )
          end

        public
        # math
          def qt_cmp_l(r) res=numer_func_l(r, :<=>); return res if res == QT_Missing::INSTANCE; QT_Number.new( -res.num_val ) end
          def qt_add_l(r) numer_func_l(r, :+) end
          def qt_sub_l(r) numer_func_l(r, :-) end
          def qt_mul_l(r) numer_func_l(r, :*) end
          def qt_div_l(r) numer_func_l(r, :/) end
          def qt_mod_l(r) numer_func_l(r, :%) end
          def qt_pow_l(r) numer_func_l(r, :**) end

          def qt_cmp_r(l) res=numer_func_r(l, :<=>); return res if res == QT_Missing::INSTANCE; QT_Number.new( -res.num_val )  end
          def qt_add_r(l) numer_func_r(l, :+) end
          def qt_sub_r(l) numer_func_r(l, :-) end
          def qt_mul_r(l) numer_func_r(l, :*) end
          def qt_div_r(l) numer_func_r(l, :/) end
          def qt_mod_r(l) numer_func_r(l, :%) end
          def qt_pow_r(l) numer_func_r(l, :**) end
end
