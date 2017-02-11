class QT_Default < QT_Object
  attr_accessor :source_val
  def text_val; @source_val.to_s end
  def self.from(source_val)
    new(source_val.to_sym)
  end

  def initialize(source_val)
    fail("Source for #{self.class} is not a Symbol, but `#{source_val.class}`") unless source_val.is_a?(Symbol)
    @source_val = source_val
  end

  def to_s
    @source_val.to_s
  end

  def ==(other)
    other.is_a?(QT_Default) && @source_val == other.source_val
  end

  def +(other)
    raise unless other.is_a?(QT_Default)
    self.class::from( @source_val.to_s + other.source_val.to_s )
  end

  def hash
    @source_val.hash
  end

 # qt methods
    # conversion
      def qt_to_text
        self
      end
      def qt_to_bool
        QT_Boolean::get(@source_val.length != 0)
      end

    # operators
      # math
        def qt_eql_l(right) QT_Boolean::get( self == right ) end
        def qt_eql_r(left) QT_Boolean::get( self == left ) end
        def qt_add(right)
          right = right.qt_to_text or return
          QT_Default::from( @source_val.to_s + right.text_val.to_s )
        end

        def qt_add_r(left)
          left = left.qt_to_text or return
          QT_Default::from( left.text_val.to_s + @source_val.to_s )
        end

end
