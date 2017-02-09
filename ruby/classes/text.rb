require_relative 'object'
class QT_Text < QT_Object

  attr_reader :text_val
  def self.from(source:)
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
    # methods
      def qt_length
        QT_Number.new(num_val: @text_val.length)
      end
    # conversion
      def qt_to_text
        self
      end
      def qt_to_bool
        QT_Boolean::get(@text_val.length != 0)
      end

    # operators
      private
      def text_func(right:, lmeth:, rmeth: :qt_to_text)
          right = right.method(rmeth).() or return
          QT_Text.new(text_val: @text_val.method(lmeth).call(right.text_val))
        end
        def text_func_r(left:, lmeth:, rmeth: :qt_to_text)
          left = left.method(rmeth).() or return
          QT_Text.new(text_val: left.text_val.method(lmeth).call(@text_val) )
        end
      public

      # math
        def qt_cmp(right:)
          return unless right.is_a?(QT_Text)
          QT_Number.new(num_val: @text_val <=> right.text_val)
        end
        def qt_add(right:) text_func(right: right, lmeth: :+) end
        def qt_mul(right:) text_func(right: right, lmeth: :*, rmeth: :qt_to_num) end
        def qt_add_r(right:) text_func_r(right: right, lmeth: :+) end
end







