class QT_Object; end

require_relative 'boolean'
require_relative 'null'

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
    def qt_nil? # the reason this isn't a qt method is because it's just an alias that i'll be using over and over.
      self == QT_Null::INSTANCE
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
        def qt_get(pos:, type:) end
        def qt_set(pos:, val:, type:) end
        def qt_del(pos:, type:) end
        def qt_peek(amnt:)
          qt_get(pos: amnt, type: :STACK)
        end

        def qt_next(amnt:)
          res = qt_peek(amnt: amnt)
          qt_del(pos: amnt, type: :STACK)
          res
        end

      # misc
        def qt_call(args:, universe:, stream:, parser:) end

        def qt_regex_match(right)
          l = qt_regex_match_l(right) 
          return l unless l.qt_nil?
          right.qt_regex_match_r(self)
        end
        def qt_regex_match_l(right) QT_Null::INSTANCE end
        def qt_regex_match_r(left) QT_Null::INSTANCE end
      # math
        def qt_add(right)
          return res unless (res = qt_add_r(right)).qt_nil?
          right.qt_add_l(self)
        end
        def qt_sub(right)
          return res unless (res = qt_sub_r(right)).qt_nil?
          right.qt_sub_l(self)
        end
        def qt_mul(right)
          return res unless (res = qt_mul_r(right)).qt_nil?
          right.qt_mul_l(self)
        end
        def qt_div(right)
          return res unless (res = qt_div_r(right)).qt_nil?
          right.qt_div_l(self)
        end
        def qt_mod(right)
          return res unless (res = qt_mod_r(right)).qt_nil?
          right.qt_mod_l(self)
        end
        def qt_pow(right)
          return res unless (res = qt_pow_r(right)).qt_nil?
          right.qt_pow_l(self)
        end

        def qt_add_r(left:); end
        def qt_sub_r(left:); end
        def qt_mul_r(left:); end
        def qt_div_r(left:); end
        def qt_mod_r(left:); end
        def qt_pow_r(left:); end

      # comparison
        # def qt_cmp(right:) end
        def qt_eql(right)
          return res unless (res = qt_eql_r(right)).qt_nil?
          return res unless (res = right.qt_eql_l(self)).qt_nil?
          return res.qt_equal( QT_Number::ZERO ) unless (res = qt_cmp(right)).qt_nil?
          QT_False::INSTANCE
        end
        # def qt_neq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val != 0) end
        # def qt_gth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == 1) end
        # def qt_lth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == -1) end
        # def qt_leq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val <= 0) end
        # def qt_geq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val >= 0) end

        def qt_cmp_r(left:) QT_Null::INSTANCE end
        def qt_eql_r(left:) QT_Null::INSTANCE end
        def qt_lth_r(left:) QT_Null::INSTANCE end
        def qt_gth_r(left:) QT_Null::INSTANCE end
        def qt_neq_r(left:) QT_Null::INSTANCE end
        def qt_leq_r(left:) QT_Null::INSTANCE end
        def qt_geq_r(left:) QT_Null::INSTANCE end

        def qt_cmp_l(left:) QT_Null::INSTANCE end
        def qt_eql_l(left:) QT_Null::INSTANCE end
        def qt_lth_l(left:) QT_Null::INSTANCE end
        def qt_gth_l(left:) QT_Null::INSTANCE end
        def qt_neq_l(left:) QT_Null::INSTANCE end
        def qt_leq_l(left:) QT_Null::INSTANCE end
        def qt_geq_l(left:) QT_Null::INSTANCE end

      # logic
        def qt_not; qt_to_bool.qt_not end

end













