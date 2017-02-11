class QT_Object; end

require_relative 'boolean'
require_relative 'null'
require_relative 'missing'

class QT_Object
  def self.from(source) #used when directly instatiating it, not copying, etc
    new 
  end

  def inspect
    "#{self.class}(#{to_s})"
  end

  def to_s
    ''
  end

  def eql?(other)
    self == other
  end

  # qt methods
    def qt_missing? # the reason this isn't a qt method is because it's just an alias that i'll be using over and over.
      false
    end
    def qt_nil?
      false
    end

    # methods
      def qt_method(meth:) end
      def qt_length; end
    # conversion
      def qt_to_num;  end
      def qt_to_text; QT_Text.new(to_s) end
      def qt_to_bool; QT_Boolean::get(true) end

    # operators 
      # access
        def qt_get(pos, type:) end
        def qt_set(pos, val, type:) end
        def qt_del(pos, type:) end
        def _peek(amnt=QT_Number::ONE)
          qt_get(amnt, type: :STACK)
        end

        def _next(amnt=QT_Number::ONE)
          res = _peek(amnt)
          qt_del(amnt, type: :STACK)
          res
        end

      # misc
        def qt_call(args:, universe:, stream:, parser:) end


        # def qt_cmp(right:) end
        def qt_eql(right)
          res = qt_eql_r(right); return res unless res.qt_missing?
          res = right.qt_eql_l(self); return res unless res.qt_missing?
          # return res.qt_equal( QT_Number::ZERO ) unless (res = qt_cmp(right)).qt_missing?
          QT_False::INSTANCE
        end
        # def qt_neq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val != 0) end
        # def qt_gth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == 1) end
        # def qt_lth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == -1) end
        # def qt_leq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val <= 0) end
        # def qt_geq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val >= 0) end
        def qt_rgx(right) res = qt_rgx_l(right); return res unless res.qt_missing?; right.qt_rgx_r(self) end

      # math
        def qt_cmp(right) res = qt_cmp_r(right); return res unless res.qt_missing?; right.qt_cmp_l(self) end
        def qt_add(right) res = qt_add_r(right); return res unless res.qt_missing?; right.qt_add_l(self) end
        def qt_sub(right) res = qt_sub_r(right); return res unless res.qt_missing?; right.qt_sub_l(self) end
        def qt_mul(right) res = qt_mul_r(right); return res unless res.qt_missing?; right.qt_mul_l(self) end
        def qt_div(right) res = qt_div_r(right); return res unless res.qt_missing?; right.qt_div_l(self) end
        def qt_mod(right) res = qt_mod_r(right); return res unless res.qt_missing?; right.qt_mod_l(self) end
        def qt_pow(right) res = qt_pow_r(right); return res unless res.qt_missing?; right.qt_pow_l(self) end

        def qt_add_r(_) QT_Missing::INSTANCE end
        def qt_sub_r(_) QT_Missing::INSTANCE end
        def qt_mul_r(_) QT_Missing::INSTANCE end
        def qt_div_r(_) QT_Missing::INSTANCE end
        def qt_mod_r(_) QT_Missing::INSTANCE end
        def qt_pow_r(_) QT_Missing::INSTANCE end
        def qt_rgx_l(_) QT_Missing::INSTANCE end
        def qt_cmp_r(_) QT_Missing::INSTANCE end
        def qt_eql_r(_) QT_Missing::INSTANCE end
        def qt_lth_r(_) QT_Missing::INSTANCE end
        def qt_gth_r(_) QT_Missing::INSTANCE end
        def qt_neq_r(_) QT_Missing::INSTANCE end
        def qt_leq_r(_) QT_Missing::INSTANCE end
        def qt_geq_r(_) QT_Missing::INSTANCE end


        def qt_add_r(_) QT_Missing::INSTANCE end
        def qt_sub_r(_) QT_Missing::INSTANCE end
        def qt_mul_r(_) QT_Missing::INSTANCE end
        def qt_div_r(_) QT_Missing::INSTANCE end
        def qt_mod_r(_) QT_Missing::INSTANCE end
        def qt_pow_r(_) QT_Missing::INSTANCE end
        def qt_rgx_r(_) QT_Missing::INSTANCE end
        def qt_cmp_l(_) QT_Missing::INSTANCE end
        def qt_eql_l(_) QT_Missing::INSTANCE end
        def qt_lth_l(_) QT_Missing::INSTANCE end
        def qt_gth_l(_) QT_Missing::INSTANCE end
        def qt_neq_l(_) QT_Missing::INSTANCE end
        def qt_leq_l(_) QT_Missing::INSTANCE end
        def qt_geq_l(_) QT_Missing::INSTANCE end


      # logic
        def qt_not; qt_to_bool.qt_not end

end












