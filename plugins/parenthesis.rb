module Parenthesis
  module_function
  
  L_PAREN = ['[', '(', '{']
  R_PAREN = [']', ')', '}']
  
  def parse(stream, universe, parser)
    # stream.next if L_PAREN.include? stream.peek
    if L_PAREN.include? stream.peek
      stream.next
    end
  end

  def handle(token, stream, universe, parser)
    container = universe.to_globals
    start_paren = token # is first paren
    parens = 1
    catch(:EOF) {
      until parens == 0 do
        if L_PAREN.include?(stream.peek)
          parens += 1
        elsif R_PAREN.include?(stream.peek)
          parens -= 1
        end
        container << stream.next
      end
      end_paren = container.pop
      universe << container#parser.parse_all(container, universe.to_globals)
      return
    }
    raise "No end parenthesis for `#{start_paren}` found"

  end

end