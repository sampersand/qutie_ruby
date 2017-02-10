require_relative 'universe'

module Universe
  L_PARENS = ['[', '(', '{']
  R_PARENS = [']', ')', '}']

  module_function
  
  def next_token!(stream:, universe:, parser:, **_)
    return unless stream.peek_any?(vals: L_PARENS)
    start_paren = stream.next
    new_container = start_paren
    parens = 1
    parser.catch_EOF(universe) {
      # this will break if there are uneven parens inside comments
      until parens == 0 do
        # this is very hacky right here
        begin # UNSAFE AND HACKY
          if stream.peek_any?(vals: ["'", '"', '`'])
            quote = stream.next
            new_container << quote
            until stream.peek?(str: quote)
              new_container << stream.next if stream.peek?(str: '\\')
              new_container << stream.next
            end
            new_container << stream.next
            next
          end

          if stream.peek_any?(vals: ['#', '//'])
            new_container << stream.next until stream.peek?(str: "\n")
            new_container << stream.next
            next
          end

          if stream.peek_any?(vals: ['/*'])
            new_container << stream.next until stream.peek?(str: '*/')
            new_container << stream.next(amnt: 2)
            next
          end
        end

        if stream.peek_any?(vals: L_PARENS)
          parens += 1
        elsif stream.peek_any?(vals: R_PARENS)
          parens -= 1
        elsif stream.peek?(str: '\\')
          new_container << stream.next
        end
        new_container << stream.next
      end
      nil
    }
    new_container
  end

  def handle(token:, universe:, **_)
    universe << QT_Universe::from(source: token, current_universe: universe)
  end

end