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
    case right
    when QT_Text
      fail "TODO"
    when QT_Default
      res = @regex_val =~ right.source_val
      res ? QT_Number.new( res ) : QT_Null::INSTANCE
    else QT_Missing::INSTANCE
    end
  end

  def qt_rgx_r(left)
    case left
    when QT_Text
      fail "TODO"
    when QT_Default
      res = @regex_val =~ left.source_val
      res ? QT_Number.new( res ) : QT_Null::INSTANCE
    else QT_Missing::INSTANCE
    end
  end

end






