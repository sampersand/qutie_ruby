class QT_Object
  def self.from(source:) #used when directly instatiating it, not copying, etc
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

    # methods
      def qt_method(meth:); end
      def qt_length; end
    # conversion
      def qt_to_num;  end
      def qt_to_text; QT_Text.new(text_val: to_s) end
      def qt_to_bool; QT_Boolean::get(true) end

    # operators 
      # access
        def qt_index(pos:, type:);  end
        def qt_set(pos, val:, type:);  end
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
        def qt_eql(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == 0) end
        def qt_neq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val != 0) end
        def qt_gth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == 1) end
        def qt_lth(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val == -1) end
        def qt_leq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val <= 0) end
        def qt_geq(right:) ret = qt_cmp(right: right); ret && QT_Boolean::get(ret.num_val >= 0) end

        def qt_cmp_r(left:); res = qt_cmp(right: left); res && QT_Number.new(num_val: -res.num_val) end
        def qt_eql_r(left:); qt_eql(right: left) end
        def qt_lth_r(left:); qt_gth(right: left) end
        def qt_gth_r(left:); qt_lth(right: left) end
        def qt_neq_r(left:); qt_neq(right: left) end
        def qt_leq_r(left:); qt_geq(right: left) end
        def qt_geq_r(left:); qt_leq(right: left) end

      # logic
        def qt_not; qt_to_bool.qt_not end

end













