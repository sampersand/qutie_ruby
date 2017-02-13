require_relative 'text'

module Text
  QUOTES = [ QT_Default.new( :"'" ),
             QT_Default.new( :'"' ),
             QT_Default.new( :'`' ) ]

  ESCAPE = QT_Default.new( :'\\' )

  module_function

  def escape(env, stream)
    case (chr=stream._next)
    when QT_Default.new( :'0' ) then QT_Default.new( :"\u0000" )
    when QT_Default.new( :n )   then QT_Default.new( :"\n"     )
    when QT_Default.new( :t )   then QT_Default.new( :"\t"     )
    when QT_Default.new( :r )   then QT_Default.new( :"\r"     )
    when QT_Default.new( :f )   then QT_Default.new( :"\f"     )
    when QT_Default.new( :u )   then QT_Default.new( stream._next( env, 4 ).text_val.to_i(16).chr(Encoding::UTF_8 ).to_sym )
    when QT_Default.new( :U )   then QT_Default.new( stream._next( env, 8 ).text_val.to_i(16).chr(Encoding::UTF_16).to_sym )
    else chr
    end
  end
  def next_token!(env)
    stream = env.stream

    return unless QUOTES.any?{ |q| q._eql?( stream._peek(env, q._length ), env)}
    start_quote = stream._next(env) # if quotes change length this will break
    end_quote = nil
    body = QT_Default::EMPTY

    catch(:EOF) do
      until start_quote._eql?( stream._peek(env,  start_quote._length ), env)
        if ESCAPE._eql?( stream._peek(env), env )
          stream._next(env)
          body = body.qt_add( escape(env, stream), env)
        else
          body = body.qt_add( stream._next(env), env)
        end
      end
      end_quote = stream._next(env, start_quote._length )
      fail unless start_quote._eql?( end_quote, env )
      true
    end or throw(:ERROR, QTE_Syntax_EOF.new($QT_CONTEXT.current,
                                                "Reached EOF before finishing string starting with: #{start_quote}"))
    QT_Text::from( body, env, quotes: [start_quote, end_quote] )
  end

  def handle(token, env)
    env.universe << token
  end
end




