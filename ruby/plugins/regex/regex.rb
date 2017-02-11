class QT_Regex < QT_Object

  attr_reader :regex_val
  def self.from(source)
    new(source[1...-1])
  end

  def initialize(regex_val)
    @regex_val = regex_val
  end

  def to_s
    "/#{@regex_val}/"
  end

  def ==(other)
    other.is_a?(QT_Regex) && @regex_val == other.regex_val
  end

  def hash
    @regex_val.hash
  end
  
  def qt_rgx_l(right)
    return QT_Missing unless right.respond_to?(:text_val)
    res = @regex_val =~ right.text_val
    res ? QT_Number.new( res ) : QT_Null::INSTANCE
  end

  def qt_rgx_r(left)
    return QT_Missing unless left.respond_to?(:text_val)
    res = left.text_val =~ @regex_val
    res ? QT_Number.new( res ) : QT_Null::INSTANCE
  end

end





