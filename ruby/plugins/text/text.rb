class QT_Text < QT_Object

  attr_reader :text_val
  attr_accessor :quotes
  def self.from(source, _env, quotes:)
    fail "Bad source type `#{source.class}`" unless source.is_a?(QT_Default)
    new( source.text_val, quotes: quotes )
  end

  def initialize(text_val, quotes: nil)
    @text_val = text_val
    raise unless text_val.is_a?(String)
    @quotes = quotes || gen_quotes
  end

  EMPTY = new( '', quotes: [ QT_Default.new( :"'" ), QT_Default.new( :"'" ) ] )
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
      def qt_to_text(_env)
        clone
      end
      def qt_to_num(env)
        QT_Number::from( self, env )
      end

      def qt_to_bool
        QT_Boolean::get(@text_val.length != 0)
      end

    # operators
      # access
      def qt_get(pos, type:)
        # ignores type
        text = @text_val[(pos.qt_to_num or return).num_val]
        text and QT_Text.new(text) or QT_Null::INSTANCE
      end

      def qt_eval(env)
        raise unless @quotes[0] == @quotes[1] #why wouldn't they be?
        case @quotes[0].text_val
        when '`' then self.class.new( `#{@text_val}` )
        when "'" 
          result = env.parser.process( input: @text_val )
          QT_Universe.new(body: '', universe: result.universe, parens: ['<', '>']) #to fix
        when '"' 
          result = env.parser.process( input: @text_val, universe: env.universe )
          QT_Universe.new(body: '', universe: result, parens: ['<', '>']) #to fix
        else fail "IDK HOW TO DEAL WITH QUOTE TYPE #{@quotes[0]}"
        end
      end

      def qt_eql_l(r) QT_Boolean::get( self == r ) end
      def qt_eql_r(l) QT_Boolean::get( self == l ) end


      private
        def text_func_r(left, rmeth, env, lmeth=:qt_to_text)
          left = left.method(lmeth).() or return
          QT_Text.new(left.text_val.method(rmeth).call(@text_val, env), quotes: @quotes)
        end
        def text_func_l(right, lmeth, env, rmeth=:qt_to_text)
          right = right.method(rmeth).() or return
          QT_Text.new(@text_val.method(lmeth).call(right.text_val, env), quotes: @quotes)
        end
      public
      # math
        def qt_cmp(right, _env)
          return unless right.is_a?(QT_Text)
          QT_Number.new(@text_val <=> right.text_val)
        end
        def qt_add_r(left, env) text_func_r(left, :+, env) end
        def qt_mul(right, env) text_func_r(right, :*, env, :qt_to_num) end
        def qt_add_l(right, env) text_func_l(right, :+, env) end
end







