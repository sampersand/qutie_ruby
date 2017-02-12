class QT_Object; end

require_relative 'boolean'
require_relative 'null'
require_relative 'missing'

class QT_Object
  def self.from(source) #used when directly instatiating it, not copying, etc
    new 
  end

  def inspect
    "#{self.class}(#{inspect_to_s})"
  end

  def inspect_to_s
    to_s
  end

  def to_s
    ''
  end

  def eql?(other)
    self == other
  end

  def to_i; qt_to_num end
  def +(other)   qt_add(other) end
  def -(other)   qt_sub(other) end
  def *(other)   qt_mul(other) end
  def /(other)   qt_div(other) end
  def %(other)   qt_mod(other) end
  def **(other)  qt_pow(other) end
  def =~(other)res=qt_rgx other;res._nil??nil:res.to_i end
  def <=>(other)res=qt_cmp other;res._nil??nil:res.to_i end
  def ==(other)qt_eql(other).bool_val end

  # qt methods
    def _missing? # the reason this isn't a qt method is because it's just an alias that i'll be using over and over.
      false
    end
    def _nil?
      false
    end

    # methods
      def qt_method(meth:) end
      def qt_length; QT_Missing::INSTANCE end
    # conversion
      def qt_to_num; QT_Missing::INSTANCE end
      def qt_to_text; QT_Text.new(to_s) end
      def qt_to_bool; QT_Boolean::get(true) end

    # operators 
      # access
        def qt_get(pos, type:) QT_Missing::INSTANCE end
        def qt_set(pos, val, type:) QT_Missing::INSTANCE end
        def qt_del(pos, type:) QT_Missing::INSTANCE end
        def _peek(amnt=1)
          qt_get(QT_Number.new(num_val: amnt), type: :STACK)
        end
        def _next(amnt=1)
          res = _peek(amnt)
          qt_del(QT_Number.new(num_val: amnt), type: :STACK)
          res
        end
      # misc
        def qt_call(args:, universe:, stream:, parser:) end


        # def qt_cmp(right:) end
        def qt_eql(right)
          res = qt_eql_l(right); return res unless res._missing?
          res = right.qt_eql_r(self); return res unless res._missing?
          # return res.qt_equal( QT_Number::ZERO ) unless (res = qt_cmp(right))._missing?
          QT_False::INSTANCE
        end
        def qt_neq(right) qt_eql(right).qt_not  end
        def qt_gth(right)
          cmp = qt_cmp(right)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val < 0 )
        end

        def qt_lth(right)
          cmp = qt_cmp(right)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val > 0 )
        end
        def qt_leq(right)
          cmp = qt_cmp(right)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val >= 0 )
        end
        def qt_geq(right)
          cmp = qt_cmp(right)
          cmp._missing? ? QT_Missing::INSTANCE : QT_Boolean::get( cmp.num_val <= 0 )
        end

        def qt_rgx(right) res = qt_rgx_l(right); return res unless res._missing?; right.qt_rgx_r(self) end

      # math
        def qt_cmp(right) res = qt_cmp_l(right); return res unless res._missing?; right.qt_cmp_r(self) end
        def qt_add(right)
          res = qt_add_l(right)
          return res unless res._missing?
          res = right.qt_add_r(self)
          return res unless res._missing?
          throw :ERROR, [ QT_MethodMissingError, :qt_add, self, right ]
        end
        def qt_sub(right) res = qt_sub_l(right); return res unless res._missing?; right.qt_sub_r(self) end
        def qt_mul(right) res = qt_mul_l(right); return res unless res._missing?; right.qt_mul_r(self) end
        def qt_div(right) res = qt_div_l(right); return res unless res._missing?; right.qt_div_r(self) end
        def qt_mod(right) res = qt_mod_l(right); return res unless res._missing?; right.qt_mod_r(self) end
        def qt_pow(right) res = qt_pow_l(right); return res unless res._missing?; right.qt_pow_r(self) end

        def qt_add_r(_) QT_Missing::INSTANCE end
        def qt_sub_r(_) QT_Missing::INSTANCE end
        def qt_mul_r(_) QT_Missing::INSTANCE end
        def qt_div_r(_) QT_Missing::INSTANCE end
        def qt_mod_r(_) QT_Missing::INSTANCE end
        def qt_pow_r(_) QT_Missing::INSTANCE end
        def qt_rgx_r(_) QT_Missing::INSTANCE end
        def qt_cmp_r(_) QT_Missing::INSTANCE end
        def qt_eql_r(_) QT_Missing::INSTANCE end
        def qt_lth_r(_) QT_Missing::INSTANCE end
        def qt_gth_r(_) QT_Missing::INSTANCE end
        def qt_neq_r(_) QT_Missing::INSTANCE end
        def qt_leq_r(_) QT_Missing::INSTANCE end
        def qt_geq_r(_) QT_Missing::INSTANCE end


        def qt_add_l(_) QT_Missing::INSTANCE end
        def qt_sub_l(_) QT_Missing::INSTANCE end
        def qt_mul_l(_) QT_Missing::INSTANCE end
        def qt_div_l(_) QT_Missing::INSTANCE end
        def qt_mod_l(_) QT_Missing::INSTANCE end
        def qt_pow_l(_) QT_Missing::INSTANCE end
        def qt_rgx_l(_) QT_Missing::INSTANCE end
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












