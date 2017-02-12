class QT_Text < QT_Object

  attr_reader :text_val
  def self.from(source, quotes:)
    fail "Bad source type `#{source.class}`" unless source.is_a?(QT_Default)
    new( source.source_val, quotes: quotes )
  end

  def initialize(text_val, quotes: nil)
    @text_val = text_val
    @quotes = quotes || gen_quotes
  end

  def gen_quotes
    ['' ,'']
    # if @text_val =~ /(?<!\\)'/
    #   if @text_val =~ /(?<!\\)"/

    #   else 
    #     "\"#{@text_val}\""
    #   end
    # else 
    #   "'#{@text_val}'"
    # end
  end

  def to_s
    "#{@quotes[0]}#{@text_val}#{@quotes[1]}"
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
        QT_Number.new(@text_val.length)
      end

    # conversion
      def qt_to_text
        self
      end
      def qt_to_bool
        QT_Boolean::get(@text_val.length != 0)
      end

    # operators
      # access
      def qt_get(pos:, type: )
        # ignores type
        text = @text_val[(pos.qt_to_num or return).num_val]
        text and QT_Text.new(text) or QT_Null::INSTANCE
      end

      def qt_eql_l(r) QT_Boolean::get( self == r ) end
      def qt_eql_r(l) QT_Boolean::get( self == l ) end


      private
        def text_func_r(right, lmeth, rmeth=:qt_to_text)
          right = right.method(rmeth).() or return
          QT_Text.new(@text_val.method(lmeth).call(right.text_val), quotes: @quotes)
        end
        def text_func_l(left, lmeth, rmeth=:qt_to_text)
          left = left.method(rmeth).() or return
          QT_Text.new(left.text_val.method(lmeth).call(@text_val), quotes: @quotes)
        end
      public
      # math
        def qt_cmp(right:)
          return unless right.is_a?(QT_Text)
          QT_Number.new(@text_val <=> right.text_val)
        end
        def qt_add_r(left) text_func_r(left, :+) end
        def qt_mul(right) text_func_r(right, :*, :qt_to_num) end
        def qt_add_l(right) text_func_l(right, :+) end
end







