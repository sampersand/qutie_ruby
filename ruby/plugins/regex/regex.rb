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
  
  def qt_regex_match_l(right)
    return unless left.is_a?(QT_Text)
    res = @regex_val =~ right.text_val
    res ? QT_Number.new(res) : QT_Null::INSTANCE
  end

  def qt_regex_match_r(left)
    return unless left.is_a?(QT_Text)
    res = left.text_val =~ @regex_val
    res ? QT_Number.new(res) : QT_Null::INSTANCE
  end

end






