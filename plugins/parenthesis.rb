module Parenthesis
  module_function
  
  R_PAREN = ['[', '(', '{']
  L_PAREN = [']', ')', '}']
  # L_PAREN_CLASS = Struct.new(:paren)

  def parse_rparen(stream, tokens, parser)
    if R_PAREN.include? stream.peek

      container = tokens.clone_knowns
      container.parens[0] = stream.next

      parens = 1
      until stream.empty? || parens == 0 do
        container.push stream.next
        if R_PAREN.include?(container.last)
          parens += 1
        end
        if L_PAREN.include?(container.last)
          parens -= 1
        end
      end
      container.parens[1] = container.pop
      tokens.push container
      true
    end
  end
  
  # def parse_lparen(stream, tokens, parser)
  #   if L_PAREN.include? stream.peek
  #     tokens.push L_PAREN_CLASS.new(stream.next)
  #     true
  #   end
  # end

  # def parse_comma(stream, tokens, parser)
  #   # if stream.peek == ','
  #   #   stream.next
  #   #   :retry
  #   # end
  # end

  def parse(stream, tokens, parser)
    parse_rparen(stream, tokens, parser)#||
    # parse_lparen(stream, tokens, parser) ||
    # parse_comma(stream, tokens, parser)
  end

end