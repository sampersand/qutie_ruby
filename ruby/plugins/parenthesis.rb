module Parenthesis
  module_function
  
  L_PAREN = ['[', '(', '{']
  R_PAREN = [']', ')', '}']
  
  def next_token!(stream, universe, parser)
    return unless stream.peek?(*L_PAREN)
    start_paren = stream.next!(1)
    new_container = start_paren
    parens = 1
    parser.catch_EOF(universe) {
      # this will break if there are uneven parens inside comments
      until parens == 0 do
        if stream.peek?(*L_PAREN)
          parens += 1
        elsif stream.peek?(*R_PAREN)
          parens -= 1
        elsif stream.peek?('\\')
          new_container << stream.next!
        end
        new_container << stream.next!(1)
      end
      nil
    }
    new_container[1...-1]
  end

  def handle(token, stream, universe, parser)
    universe << universe.spawn_new_stack(new_stack: token.each_char.to_a)
  end

end