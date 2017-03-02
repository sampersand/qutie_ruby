module Universe
  require 'plugins/default/default'
  assert defined? QT_Default, "QT_Default wasn't imported properly"

  require_relative 'universe'
  assert defined? QT_Universe, "QT_Universe wasn't imported properly"


  L_PARENS = [ QT_Default.new( :'(' ),
               QT_Default.new( :'[' ),
               QT_Default.new( :'{' ) ]
  L_PARENS.each_with_index{ |e, i| assert_is_a(e, QT_Default, "#{name}::L_PARENS[#{i}]") }

  R_PARENS = [ QT_Default.new( :')' ),
               QT_Default.new( :']' ),
               QT_Default.new( :'}' ) ]
  R_PARENS.each_with_index{ |e, i| assert_is_a(e, QT_Default, "#{name}::R_PARENS[#{i}]") }

  ESCAPE = QT_Default.new( :'\\' )
  assert_is_a(ESCAPE, QT_Default, "#{name}::ESCAPE")

  module_function
  
  def next_token(env)
    assert_is_a(env, Environment, 'env')

    stream = env.stream
    universe = env.universe

    assert_is_a(stream, QT_Universe, 'env.stream')
    assert_is_a(universe, QT_Universe, 'env.universe')

    return unless L_PARENS.any?{ |lp| lp._eql?( stream._peek(env), env ) }

    start_paren = stream._next(env)
    assert_is_a(start_paren, QT_Default, 'start_paren (aka stream._next)')
    body = QT_Default::EMPTY
    parens = 1

    L_PARENS.each_with_index{ |e, i| assert_is_a(e, QT_Default, "#{name}::L_PARENS[#{i}]") }
    R_PARENS.each_with_index{ |e, i| assert_is_a(e, QT_Default, "#{name}::R_PARENS[#{i}]") }
    assert_is_a(ESCAPE, QT_Default, "#{name}::ESCAPE")
    catch(:EOF) do
      loop do
        assert_is_a(body, QT_Default, 'body')
        # this is very hacky right here
          # begin # UNSAFE AND HACKY
          #   if ["'", '"', '`'].any?{|q| q._eql?(stream._peek(env),env)}
          #     quote = stream._next(env)
          #     body = body.qt_add(quote, env)
          #     until quote._eql?( stream._peek(env), env )
          #       body << stream.next if stream.peek?(str: '\\')
          #       body << stream.next
          #     end
          #     body << stream.next
          #     next
          #   end

          #   if stream.peek_any?(vals: ['#', '//'])
          #     body << stream.next until stream.peek?(str: "\n")
          #     body << stream.next
          #     next
          #   end

          #   if stream.peek_any?(vals: ['/*'])
          #     body << stream.next until stream.peek?(str: '*/')
          #     body << stream.next(amnt: 2)
          #     next
          #   end
          # end
        if L_PARENS.any?{ |lp| lp._eql?( stream._peek(env), env ) }
          parens += 1
        elsif R_PARENS.any?{ |rp| rp._eql?( stream._peek(env), env ) }
          parens -= 1
          break if parens == 0
        elsif ESCAPE._eql?( stream._peek(env), env )
          body = body.qt_add( stream._next(env), env )
        end
        body = body.qt_add( stream._next(env), env )
      end
      true
    end or throw(:ERROR, QTE_Syntax_EOF.new("Reached EOF before finishing universe starting with: #{start_paren}"))
    assert_is_a(body, QT_Default, 'body')

    end_paren = stream._next(env)
    assert_is_a(end_paren, QT_Default, 'end_paren (aka stream._next)')
    res = QT_Universe::from(body, env, parens: [start_paren, end_paren])
    assert_is_a(res, QT_Universe, "#{name}::#{__callee__}'s return value")
    res
  end

  def handle(token, env)
    env.universe << token
  end

end






