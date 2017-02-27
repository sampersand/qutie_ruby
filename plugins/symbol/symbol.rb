class QT_Symbol < QT_Object

  attr_reader :sym_val
  def self.from(source, _env)
    fail "INTERNAL: Bad source type `#{source.class}`" unless source.is_a?(QT_Default)
    new( source.source_val.to_sym )
  end
  
  def initialize(sym_val)
    @sym_val = sym_val
  end

  def to_s
    @sym_val.to_s
  end

  def ==(other)
    other.is_a?(QT_Symbol) && @sym_val == other.sym_val
  end

  def hash
    @sym_val.hash
  end

  # qt methods
    # conversion
      def qt_eql(right, env)
        QT_Boolean::get( self == right )
      end

      def qt_to_text(_env)
        QT_Text.new(to_s)
      end

end
