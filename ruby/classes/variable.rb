require 'classes/object'
class QT_Variable < QT_Object

  attr_reader :value
  def self.from(source:)
    new(value: source.to_sym )
  end
  
  def initialize(value:)
    @value = value
  end

  def to_s
    @value.to_s
  end

  def ==(other)
    other.is_a?(QT_Variable) && @value == other.value
  end

  def hash
    @value.hash
  end

  # qt methods
    # conversion
      def qt_eql(right:) self == right end
      def qt_eql_r(left:) self == left end

      def qt_to_text
        Text::QT_Text.new(text_val: to_s)
      end

end
