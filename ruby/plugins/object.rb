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

end