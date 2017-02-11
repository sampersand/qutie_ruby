class QT_Variable < QT_Object

  attr_reader :var_val
  def self.from(source:)
    fail "Bad source type `#{source.class}`" unless source.is_a?(QT_Default)
    new( source.source_val.to_sym )
  end
  
  def initialize(var_val)
    @var_val = var_val
  end

  def to_s
    @var_val.to_s
  end

  def ==(other)
    other.is_a?(QT_Variable) && @var_val == other.var_val
  end

  def hash
    @var_val.hash
  end

  # qt methods
    # conversion
      def qt_equal(right:)
        self == right
      end

      def qt_to_text
        QT_Text.new(to_s)
      end

end
