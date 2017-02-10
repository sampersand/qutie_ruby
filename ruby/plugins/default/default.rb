require_relative 'object'
class QT_Default < QT_Object
  def self.from(source:)
    new(source: source)
  end

  def initialize(source:)
    warn("Source for #{self.class} is not a String, but `#{source.class}`)") unless source.is_a?(String)
    @source = source
  end

  def to_s
    @source.to_s
  end

  def ==(other)
    other.is_a?(QT_Default) && @source == other.source
  end

  def hash
    @source.hash
  end

 # qt methods
    # conversion
      def qt_to_text
        self
      end
      def qt_to_bool
        QT_Boolean::get(@text_val.length != 0)
      end

    # operators
      # math
        def qt_add(right:)
          right = right.qt_to_text or return
          QT_Text.new(text_val: @text_val + right.text_val)
        end

        def qt_add_r(left:)
          left = left.qt_to_text or return
          QT_Text.new(text_val: left.text_val + @text_val)
        end

end
