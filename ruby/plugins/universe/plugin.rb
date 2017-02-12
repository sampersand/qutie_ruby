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
  
  def next_token!(stream:, universe:, **_)
    return unless L_PARENS.any?{ |lp| lp == stream._peek( lp._length ) }
    start_paren = stream._next
    body = QT_Default::EMPTY
    current_context = $QT_CONTEXT.current.clone
    parens = 1
    catch(:EOF) do
      loop do
        # this is very hacky right here
        # begin # UNSAFE AND HACKY
        #   if stream.peek_any?(vals: ["'", '"', '`'])
        #     quote = stream.next
        #     body << quote
        #     until stream.peek?(str: quote)
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

        if L_PARENS.any?{ |lp| lp == stream._peek( lp._length ) }
          parens += 1
        elsif R_PARENS.any?{ |lp| lp == stream._peek( lp._length ) }
          parens -= 1
          break if parens == 0
        elsif stream._peek == ESCAPE
          body += stream._next
        end
        body += stream._next
      end
      true
    end or throw(:ERROR, QTError_Syntax_EOF.new($QT_CONTEXT.current,
                                                "Reached EOF before finishing universe starting with: #{start_paren}"))

    end_paren = stream._next
    QT_Universe::from(source: body,
                      current_universe: universe, 
                      parens: [start_paren, end_paren],
                      context: current_context)
  end

  def handle(token:, universe:, **_)
    universe << token
  end

end






