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
      parser.parse_all(func.clone, args.to_globals).stack.last
     },
    '@'  => proc { |func, args, universe, parser|
      func or raise "Invalid func #{func}"
      args or raise "Invalid args #{args}"
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
  # def parse_oper(stream, tokens, parser)
  #   oper = OPERATORS.each.find{ |oper| oper == stream.peek(oper.length) }
  #   return unless oper

  #   func = OPERATOR_FUNCTIONS[stream.next oper.length]
  #   lhs = tokens.pop
    
  #   rhs = tokens.to_globals
  #   until priority(oper) <= priority(rhs.last) || stream.empty?
  #     p stream, rhs
  #     parser.next_token(stream, rhs)
  #     if OPER_END == rhs.last
  #       last = rhs.pop
  #       stream.feed last
  #       break
  #     end
  #   end
  #   p '--'
  #   warn("[Warning] ambiguous rhs for operator `#{oper}` #{rhs}. Using `#{rhs.first}` ") unless rhs.length == 1
  #   tokens.push func.call(lhs, rhs.first, tokens, parser)
  #   true
  # end
  # def parse_break(stream, tokens, parser)
  #   case stream.peek
  #   when ';'
  #     stream.next
  #     stream.feed *[OPER_END, '$', '$']
  #     :retry
  #   when ','
  #     stream.next
  #     stream.feed *[OPER_END, '$']
  #     :retry
  #   else
  #     false
  #   end
  # end
  # def parse(stream, tokens, parser)
  #   parse_oper(stream, tokens, parser) ||
  #   parse_break(stream, tokens, parser)
  # end

end
















