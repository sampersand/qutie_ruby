require_relative 'universe'

module Universe
  L_PARENS = [ QT_Default.new( :'(' ),
               QT_Default.new( :'[' ),
               QT_Default.new( :'{' ) ]

  R_PARENS = [ QT_Default.new( :')' ),
               QT_Default.new( :']' ),
               QT_Default.new( :'}' ) ]

  ESCAPE = QT_Default.new( :'\\' )
  module_function
  
  def next_token!(env)
    stream = env.stream
    universe = env.universe
    return unless L_PARENS.any?{ |lp| lp._eql?( stream._peek(env), env ) }

    start_paren = stream._next(env)
    body = QT_Default::EMPTY
    start_line_no = $QT_CONTEXT.current.line_no
    parens = 1
    catch(:EOF) do
      loop do
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
    end or throw(:ERROR, QTE_Syntax_EOF.new($QT_CONTEXT.current,
                                                "Reached EOF before finishing universe starting with: #{start_paren}"))
    end_paren = stream._next(env)
    res=QT_Universe::from(body, env, parens: [start_paren, end_paren])
    res.__start_line_no = start_line_no
    res
  end

  def handle(token, env)
    env.universe << token
  end

end






