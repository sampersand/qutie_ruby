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
    new_container = QT_Default::EMPTY
    parens = 1
    catch(:EOF) do
      loop do
        # this is very hacky right here
        # begin # UNSAFE AND HACKY
        #   if stream.peek_any?(vals: ["'", '"', '`'])
        #     quote = stream.next
        #     new_container << quote
        #     until stream.peek?(str: quote)
        #       new_container << stream.next if stream.peek?(str: '\\')
        #       new_container << stream.next
        #     end
        #     new_container << stream.next
        #     next
        #   end

        #   if stream.peek_any?(vals: ['#', '//'])
        #     new_container << stream.next until stream.peek?(str: "\n")
        #     new_container << stream.next
        #     next
        #   end

        #   if stream.peek_any?(vals: ['/*'])
        #     new_container << stream.next until stream.peek?(str: '*/')
        #     new_container << stream.next(amnt: 2)
        #     next
        #   end
        # end

        if L_PARENS.any?{ |lp| lp == stream._peek( lp._length ) }
          parens += 1
        elsif R_PARENS.any?{ |lp| lp == stream._peek( lp._length ) }
          parens -= 1
          break if parens == 0
        elsif stream._peek == ESCAPE
          new_container += stream._next
        end
        new_container += stream._next
      end
    end

    end_paren = stream._next
    QT_Universe::from(source: new_container,
                      current_universe: universe, 
                      parens: [start_paren, end_paren] )
  end

  def handle(token:, universe:, **_)
    universe << token
  end

end






