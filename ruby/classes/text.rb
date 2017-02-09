require_relative 'object'
class QT_Text < QT_Object

  attr_reader :text_val
  def self.from(source:)
    # new(body: source[1...-1], quotes: [source[0], source[-1]])
    new(text_val: source[1...-1])
  end

  def initialize(text_val:)
    @text_val = text_val
  end

  def to_s
    if @text_val =~ /(?<!\\)'/
      if @text_val =~ /(?<!\\)"/
        if @text_val =~ /(?<!\\)`/
          "`#{@text_val.gsub(/(?<!\\)`/, '\\\\`')}`"
        else
          "`#{@text_val}`"
        end
      else 
        "\"#{@text_val}\""
      end
    else 
      "'#{@text_val}'"
    end
  end

  def ==(other)
    other.is_a?(QT_Text) && @text_val == other.text_val
  end

  def hash
    @text_val.hash
  end

  # qt methods
    # conversion
      def qt_to_text
        self
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
