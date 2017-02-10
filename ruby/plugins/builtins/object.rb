class QT_Object; end
require_relative 'boolean'
require_relative 'null'
class QT_Object
  def self.from(source) #used when directly instatiating it, not copying, etc
    new 
  end

  def true? # the reason this isn't a qt method is because it's just an alias that i'll be using over and over.
    qt_to_bool == QT_True::INSTANCE
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

    # methods
      def qt_method(meth:) end
      def qt_length; end
    # conversion
      def qt_to_num;  end
      def qt_to_text; QT_Text.new(text_val: to_s) end
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
          QT_Boolean::get(qt_regex_match_l(right) || right.qt_regex_match_r(self))
        end
        def qt_regex_match_l(right) end
        def qt_regex_match_r(left) end
      # math
        def qt_add(right:);  end
        def qt_sub(right:);  end
        def qt_mul(right:);  end
        def qt_div(right:);  end
        def qt_mod(right:);  end
        def qt_pow(right:);  end

        def qt_add_r(left:); end
        def qt_sub_r(left:); end
        def qt_mul_r(left:); end
        def qt_div_r(left:); end
        def qt_mod_r(left:); end
        def qt_pow_r(left:); end

      # comparison
        def qt_cmp(right:) end
        def qt_equals(other)
          res = qt_equals_r(right: other) || qt_equals_l(left: other) and return res
          res = qt_cmp(right: right)
          res && res.qt_to_bool
        end
        def qt_neq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val != 0) end
        def qt_gth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == 1) end
        def qt_lth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == -1) end
        def qt_leq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val <= 0) end
        def qt_geq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val >= 0) end

        def qt_cmp_r(left:); res = qt_cmp(right: left); res && QT_Number.new(num_val: -res.num_val) end
        def qt_eql_r(left:); qt_equals(right: left) end
        def qt_lth_r(left:); qt_gth(right: left) end
        def qt_gth_r(left:); qt_lth(right: left) end
        def qt_neq_r(left:); qt_neq(right: left) end
        def qt_leq_r(left:); qt_geq(right: left) end
        def qt_geq_r(left:); qt_leq(right: left) end

      # logic
        def qt_not; qt_to_bool.qt_not end

end













