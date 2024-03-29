require_relative 'plugin'
class QT_Number < QT_Object
  attr_reader :num_val

  def self.from(source, _env, base: nil)
    fail "Bad source type `#{source.class}`" unless source.respond_to?(:text_val)
    val = source.text_val
    val = val.to_i(Number::BASES[base.source_val][1].num_val) if base
    new(val.to_f, base: base)
  end

  def initialize(num_val, base: nil)
    @num_val = num_val
    @given_base = base
  end

  def to_s
    if @given_base
      return "0#{@given_base.source_val.to_s}#{@num_val.to_i.to_s(Number::BASES[@given_base.source_val][1].num_val).upcase}"
    end
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
    NEG_1 = new( -1         )
    ZERO  = new(  0         )
    ONE   = new(  1         )
    TWO   = new(  2         )

    E     = new( Math::E    )
    PI    = new( Math::PI   )
    NaN   = new( Float::NAN )

  # qt methods
    # conversion
      def qt_to_num(_env)
        clone
      end
      def qt_to_bool(_env)
        QT_Boolean::get(@num_val != 0)
      end

    # operators
        private
          def numer_func_l(right, env,  lmeth)
            # right = right.qt_to_num(env)
            return QT_Missing::INSTANCE unless right.is_a?(self.class)
            return QT_Missing::INSTANCE if right._eql?( QT_Missing::INSTANCE, env)
            QT_Number.new(@num_val.method(lmeth).call(right.num_val))
          end
          def numer_func_r(left, env, lmeth)
            # left = left.qt_to_num(env)
            return QT_Missing::INSTANCE unless left.is_a?(self.class)
            return QT_Missing::INSTANCE if left._eql?( QT_Missing::INSTANCE, env)
            QT_Number.new(left.num_val.method(lmeth).call(@num_val) )
          end

        public
        def qt_neg(_env) QT_Number.new( -@num_val ) end
        def qt_pos(_env) QT_Number.new( +@num_val ) end

        # math
          def qt_eql_l(r, e) res=qt_cmp_l(r, e);return QT_Missing::INSTANCE if res._missing?;QT_Boolean::get(res.num_val==0) end
          def qt_cmp_l(r, e) numer_func_l(r, e, :<=>)end
          def qt_add_l(r, e) numer_func_l(r, e, :+) end
          def qt_sub_l(r, e) numer_func_l(r, e, :-) end
          def qt_mul_l(r, e) numer_func_l(r, e, :*) end
          def qt_div_l(r, e) numer_func_l(r, e, :/) end
          def qt_mod_l(r, e) numer_func_l(r, e, :%) end
          def qt_pow_l(r, e) numer_func_l(r, e, :**) end

          def qt_eql_r(l, e) res=r.qt_cmp_r(self, e);return QT_Missing::INSTANCE if res._missing?;QT_Boolean::get(res.num_val==0) end
          def qt_cmp_r(l, e) numer_func_r(l, e, :<=>)end
          def qt_add_r(l, e) numer_func_r(l, e, :+) end
          def qt_sub_r(l, e) numer_func_r(l, e, :-) end
          def qt_mul_r(l, e) numer_func_r(l, e, :*) end
          def qt_div_r(l, e) numer_func_r(l, e, :/) end
          def qt_mod_r(l, e) numer_func_r(l, e, :%) end
          def qt_pow_r(l, e) numer_func_r(l, e, :**) end

end
