module Text
  require 'plugins/default/default'
  assert defined? QT_Default, "QT_Default wasn't imported properly"

  require_relative 'text'
  assert defined? QT_Text, "QT_Text wasn't imported properly"

  QUOTES = [ QT_Default.new( :"'" ),
             QT_Default.new( :'"' ),
             QT_Default.new( :'`' ) ]
  QUOTES.each_with_index{ |e, i| assert_is_a(e, QT_Default, "#{name}::QUOTES[#{i}]") }

  ESCAPE = QT_Default.new( :'\\' )
  assert_is_a(ESCAPE, QT_Default, "#{name}::ESCAPE")

  module_function

  def escape(env, stream)
    case (chr=stream._next(env))
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
  def next_token(env)
    assert_is_a(env, Environment, 'env')
    stream = env.stream
  
    assert_is_a(stream, QT_Universe, 'env.stream')
    QUOTES.each_with_index{ |e, i| assert_is_a(e, QT_Default, "#{name}::QUOTES[#{i}]") }
    assert_is_a(ESCAPE, QT_Default, "#{name}::ESCAPE")
  
    return unless QUOTES.any?{ |q| q._eql?( stream._peek(env, q._length ), env)}
    start_quote = stream._next(env) # if quotes change length this will break
    assert_is_a(start_quote, QT_Default, 'start_quote (aka stream._next)')
    end_quote = nil # so there is something after the catch EOF
    body = QT_Default::EMPTY

    catch(:EOF) do
      until start_quote._eql?( stream._peek(env,  start_quote._length ), env)

        if ESCAPE._eql?( stream._peek(env), env )
          _next = stream._next(env)
          assert ESCAPE._eql?(_next, env), "stream._peek != stream._next"
          body = body.qt_add( escape(env, stream), env)
        else
          body = body.qt_add( stream._next(env), env)
        end
        assert_is_a(body, QT_Default, 'body')
      end
      end_quote = stream._next(env, start_quote._length )

      assert_is_a(end_quote, QT_Default, 'end_quote (aka stream._next)')
      assert start_quote._eql?(end_quote, env), "start_quote (#{start_quote}) != end_quote (#{end_quote})"
      true
    end or throw(:ERROR, QTE_Syntax_EOF.new(env, "Reached EOF before finishing string starting with: #{start_quote}"))

    assert end_quote, "end quote wasn't found!"
    res = QT_Text::from( body, env, quotes: [start_quote, end_quote] )
    assert_is_a(res, QT_Text, 'QT_Text::from')
    res
  end

  def handle(token, env)

    env.universe << token
  end
end




