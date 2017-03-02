class QT_Text < QT_Object

  attr_reader :text_val
  attr_accessor :quotes
  def self.from(source, _env, quotes:)
    fail "Bad source type `#{source.class}`" unless source.is_a?(QT_Default)
    new( source.text_val, quotes: quotes )
  end

  def initialize(text_val, quotes: nil)
    @text_val = text_val
    raise text_val.class.to_s unless text_val.is_a?(String)
    @quotes = quotes || gen_quotes
  end

  EMPTY = new( '', quotes: [ QT_Default.new( :"'" ), QT_Default.new( :"'" ) ] )
  def gen_quotes
    [QT_Default.new( :"'" ), QT_Default.new( :"'" ) ]
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
      def qt_length(_env, type: ) #ignore type
        QT_Number.new(@text_val.length)
      end

    # conversion
      def qt_to_text(_env)
        clone
      end
      def qt_to_num(env)
        return QT_Missing::INSTANCE unless @text_val =~ /(\d+)|(\d+\.\d+)|(\d+(\.\d+)?[eE][+-]?\d+)/
        QT_Number::from( self, env )
      end

      def qt_to_bool(_env)
        QT_Boolean::get(@text_val.length != 0)
      end

    # operators
      def qt_method(meth, env)
        case meth.sym_val
        when :insert
          Functions::QT_BuiltinFunciton.new{ |args, env|
            text = Functions::fetch(args, env, 0, :__text)
            pos = Functions::fetch(args, env, 1, :__pos, default: QT_Number::ZERO)
            @text_val.insert((pos.qt_to_num(env) or return QT_Null::INSTANCE).num_val,
                             text.qt_to_text(env).text_val)
            self
          }
        end
      end
      # access
      def qt_get(pos, env, type:)
        # ignores type
        if pos.is_a?(QT_Symbol)
          qt_method(pos, env)
        else
          text = @text_val[(pos.qt_to_num(env) or return QT_Null::INSTANCE).num_val]
          text and QT_Text.new(text) or QT_Null::INSTANCE
        end
      end

      def qt_del(pos, env, type:)
        # ignores type
        fail unless type == QT_Symbol.new( :BOTH ) || type == QT_Symbol.new( :STACK )
        text = @text_val.slice!((pos.qt_to_num(env) or return QT_Null::INSTANCE).num_val)
        text and QT_Text.new(text) or QT_Null::INSTANCE
      end

      def qt_eval(env)
        raise unless @quotes[0] == @quotes[1] #why wouldn't they be?
        case @quotes[0].text_val
        when '`' then self.class.new( `#{@text_val}`.chomp, quotes: @quotes )
        when "'" 
          result = env.parser.process( input: @text_val ).u
          QT_Universe.new(body: '', universe: result, parens: ['<', '>']) #to fix
        when '"' 
          result = env.parser.process( input: @text_val, universe: env.u ).u
          QT_Universe.new(body: '', universe: result, parens: ['<', '>']) #to fix
        else fail "IDK HOW TO DEAL WITH QUOTE TYPE #{@quotes[0]}"
        end
      end

      def qt_eql_l(r) QT_Boolean::get( self == r ) end
      def qt_eql_r(l) QT_Boolean::get( self == l ) end


      private
        def text_func_r(left, rmeth, env, lmeth=:qt_to_text)
          left = left.method(lmeth).(env) or return
          QT_Text.new(left.text_val.method(rmeth).call(@text_val), quotes: @quotes)
        end
        def text_func_l(right, lmeth, env, rmeth=:qt_to_text)
          right = right.method(rmeth).(env) or return
          QT_Text.new(@text_val.method(lmeth).call(right.text_val), quotes: @quotes)
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







