module Parenthesis
  module_function
  
  L_PAREN = ['[', '(', '{']
  R_PAREN = [']', ')', '}']
  
  def parse(stream, universe, parser)
    # stream.next if L_PAREN.include? stream.peek
    if L_PAREN.include? stream.peek
      token = stream.next
      result = universe.class.new
      handle(token, stream, result, parser)
      raise "Result should have 1 element, that is a universe" unless result.stack.length == 1 &&
                                                                      result.stack[0].is_a?(universe.class)
      result.pop

    end
  end

  def handle(token, stream, universe, parser)
    container = universe.to_globals
    # container.parens[0] = stream.next
    stream.next # pop it
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