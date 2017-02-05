module Parenthesis
  module_function
  
  L_PAREN = ['[', '(', '{']
  R_PAREN = [']', ')', '}']
  
  def next_token!(stream, universe, parser)
    # stream.next if L_PAREN.include? stream.peek
    if stream.peek?(*L_PAREN)

      start_paren = stream.next!(1)
      new_container = universe.knowns_only
      parens = 1
      catch(:EOF) {
        # this will break if there are uneven parens inside comments
        until parens == 0 do
          if stream.peek?(*L_PAREN)
            parens += 1
          elsif stream.peek?(*R_PAREN)
            parens -= 1
          end
          new_container << stream.next!(1)
        end
        end_paren = new_container.pop # is unused
        universe << new_container
        return
      }
      raise "No end parenthesis for `#{start_paren}` found"

    end
  end

  def handle(token, stream, universe, parser)
    universe << token
  end

end