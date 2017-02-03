module Operator
  module_function
  OPERATORS = {
    '**' => proc { |l, r| l ** r},
    '*'  => proc { |l, r| l *  r},
    '/'  => proc { |l, r| l /  r},
    '%'  => proc { |l, r| l %  r},
    '+'  => proc { |l, r| l +  r},
    '-'  => proc { |l, r| l -  r},
    '='  => proc { |l, r, u| u.locals[l] = r},
    '@$'  => proc { |func, args, universe, parser| 
      func or raise "Invalid func `#{func}`"
      # args = parser.parse_all(args, universe.to_globals)
      args or raise "Invalid args `#{args}`"
      parser.parse_all(func.clone, args.to_globals).stack.last
     },
    '@'  => proc { |func, args, universe, parser|
      func or raise "Invalid func `#{func}`"
      # args = parser.parse_all(args, universe.to_globals)
      args or raise "Invalid args `#{args}`"
      parser.parse_all(func.clone, args.to_globals)
      },
  }
  OPER_ENDS = [';', ',']
  def priority(token, plugin)
    case
    when plugin == Operator
      case token
      when *OPER_ENDS then 100
      when '=' then 30
      when '+', '-' then 19
      when '*', '/', '%' then 18
      when '**', '^' then 17
      when '@', '@$' then 5
      when ':', ':=' then 4
      when  '$', '!', '?' then 1
      else raise "Unknown operator #{token}"
      end
    else 0
    end
  end
  def parse(stream, _, _)
    OPERATORS.keys.each do |oper|
      return stream.next(oper.length) if stream.peek(oper.length) == oper
    end
    OPER_ENDS.each do |oper_end|
      return stream.next(oper_end.length) if stream.peek(oper_end.length) == oper_end
    end
    nil
  end

  def handle_operends(token, universe)
    case token
    when "\n", ',' then nil
    when ';' then universe.stack.pop
    end
    
  end
  def handle(token, stream, universe, parser)
    return handle_operends(token, universe) if OPER_ENDS.include?(token)

    func = OPERATORS[token]
    lhs = universe.stack.pop
    rhs = universe.class.new
    catch(:EOF) {
      until stream.stack.empty?
        next_token = parser.parse(stream, rhs)
        if priority(token, Operator) < priority(*next_token)
          stream.feed(next_token[0])
          break
        elsif next_token[1] == Parenthesis #hacky
          next_token[1].handle(next_token[0], stream, rhs, parser)
        else
          rhs << next_token[0]
        end
      end
    }

    rhs = parser.parse_all(rhs, universe.to_globals)
    
    unless rhs.stack.length == 1
      if rhs.stack.empty?
        puts("[Error] No rhs for operator `#{token}` #{rhs}")
        exit(1)
      end
      warn("[Warning] ambiguous rhs for operator `#{token}` #{rhs}. Using `#{rhs.stack.first}` ")
    end
    universe << func.call(lhs, rhs.stack.first, universe, parser)
  end

end
