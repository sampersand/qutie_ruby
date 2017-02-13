class QT_Default < QT_Object
  attr_reader :source_val

  def text_val; @source_val.to_s end
  def self.from(source_val, _env)
    new(source_val.to_sym)
  end
  def initialize(source_val)
    fail("Source for #{self.class} is not a Symbol, but `#{source_val.class}`") unless source_val.is_a?(Symbol)
    @source_val = source_val # if this is updated, it'll break EMPTY
  end
  
  EMPTY = new( :'' )

  def to_s
    res=@source_val.to_s
    return '\_' if res == '_'
    res == ' ' ? '_' : res
  end

  def inspect_to_s; to_s.dump end

  def ==(other)
    other.is_a?(QT_Default) && @source_val == other.source_val
  end

  # def +(other)
  #   raise unless other.is_a?(QT_Default)
  #   self.class::from( @source_val.to_s + other.source_val.to_s )
  # end

  def hash
    @source_val.hash
  end

  def _length
    @source_val.length
  end

 # qt methods
    # conversion
      def qt_to_text(_env)
        QT_Text.new( text_val )
      end
      def qt_to_bool
        QT_Boolean::get(@source_val.length != 0)
      end

    # operators
      # math
        def qt_eql_l(right, _env) QT_Boolean::get( self == right ) end
        def qt_eql_r(left, _env) QT_Boolean::get( self == left ) end
        def qt_add(right, env)
          right = right.qt_to_text(env) or return
          self.class::from( @source_val.to_s + right.text_val.to_s, env )
        end

        def qt_add_r(left, env)
          left = left.qt_to_text(env) or return
          self.class::from( left.text_val.to_s + @source_val.to_s, env )
        end

end







