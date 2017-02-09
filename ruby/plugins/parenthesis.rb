module Parenthesis

  class QT_Universe < QT_Object
    def self.from(source:, current_universe:)
      warn("QT_Universe::from doesnt conform to others!")
      new(source: source,
          current_universe: current_universe,
          parens: [source[0], source[-1]])
    end
    def initialize(source:, current_universe:, parens:)
      super(source: source)
      @current_universe = current_universe
      @parens = parens
    end
  end

  L_PARENS = ['[', '(', '{']
  R_PARENS = [']', ')', '}']

  module_function
  
  def next_token!(stream, universe, parser)
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

  def handle(token, stream, universe, parser)
    universe << QT_Universe::from(source: token, current_universe: universe)
  end

end