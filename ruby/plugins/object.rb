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

  # qt methods

    # conversion
      def qt_to_num;  end
      def qt_to_text; Text::QT_Text.new(text_val: to_s) end
      # def qt_to_bool; Text::QT_Text.new(text_val: to_s) end

    # operators 
      # access
        def qt_get(key:);  end
        def qt_set(key, val:);  end
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
        def qt_eql(right:); end
        def qt_lth(right:); end
        def qt_gth(right:); end

        def qt_neq(right:)
          eql = qt_eql(right: right)
          eql && eql.qt_not
        end
        def qt_leq(right:)
          lth = qt_lth(right: right)
          lth || qt_eql(right: right)
        end
        def qt_geq(right:)
          gth = qt_gth(right: right)
          gth || qt_eql(right: right)
        end

        def qt_eql_r(left:); qt_eql(right: left) end
        def qt_lth_r(left:); qt_gth(right: left) end
        def qt_gth_r(left:); qt_lth(right: left) end
        def qt_neq_r(left:); qt_neq(right: left) end
        def qt_leq_r(left:); qt_geq(right: left) end
        def qt_geq_r(left:); qt_leq(right: left) end

      # logic
        def qt_not; qt_to_bool.qt_not end

end





