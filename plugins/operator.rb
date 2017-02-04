module Operator
  module_function
  BINARY_OPERATORS = { # order matters!
    '**' => proc { |l, r| l ** r},
    '*'  => proc { |l, r| l *  r},
    '/'  => proc { |l, r| l /  r},
    '%'  => proc { |l, r| l %  r},
    '+'  => proc { |l, r| l +  r},
    '-'  => proc { |l, r| l -  r},
    '==' => proc { |l, r| l == r },
    '<>' => proc { |l, r| l != r },
    '<=' => proc { |l, r| l <= r },
    '>=' => proc { |l, r| l >= r },
    '<'  => proc { |l, r| l <  r },
    '>'  => proc { |l, r| l >  r },

    'or'  => proc { |l, r| l || r },
    'and' => proc { |l, r| l && r },

    '='  => proc { |l, r, u| u.locals[l] = r},
    '@$' => proc { |func, args, universe, parser| parser.parse_all(func, args.to_globals).stack.last },
    '@'  => proc { |func, args, universe, parser| parser.parse_all(func, args.to_globals) },

    '.V='  => proc { |arg, pos, universe, parser| arg.locals[pos.stack[0]] = pos.stack[1] },
    '.S='  => proc { |arg, pos, universe, parser| arg.stack[pos.stack[0]] = pos.stack[1] },
    '.='  => proc { |arg, pos, universe, parser| 
      BINARY_OPERATORS[pos.stack[0].is_a?(Numeric) ? '.S=' : '.V='].(arg, pos, universe, parser)
      },
    '.S'  => proc { |arg, pos, universe, parser| arg.stack[pos] },
    '.V'  => proc { |arg, pos, universe, parser| arg.get(pos) },
    '.'  => proc { |arg, pos, universe, parser|
      res = arg.get(pos)
      res.nil?  && pos.is_a?(Integer) ? arg.stack[pos] : res
    },
  }
  UNARY_OPERS = {
    'not' => proc { |o| !o },
  }

  OPER_ENDS = [';', ',']
  def priority(token, plugin)
    case
    when plugin == Operator
      case token
      when *OPER_ENDS then 40
      when '=' then 30
      when 'or' then 25
      when 'and' then 24
      when 'not' then 23
      when '==', '<>', '<=', '>=', '<', '>' then 20
      when '+', '-' then 12
      when '*', '/', '%' then 11
      when '**', '^' then 10
      when '@$', '@' then 7
      when '.', '.S', '.V', '.=', '.S=', '.V=' then 5
      when  '$', '!', '?' then 1
      else raise "Unknown operator #{token}"
      end
    else 0
    end
  end

  def parse(stream, _, _)
    BINARY_OPERATORS.keys.each do |oper|
      return stream.next(oper.length) if stream.peek(oper.length) == oper
    end
    UNARY_OPERS.keys.each do |oper|
      return stream.next(oper.length) if stream.peek(oper.length) == oper
    end
    OPER_ENDS.each do |oper_end|
      return stream.next(oper_end.length) if stream.peek(oper_end.length) == oper_end
    end
    nil
  end

  def handle_oper_end(token, universe)
    universe.stack.pop if token == ';'
  end

  def handle_binary_oper(token, stream, universe, parser)

    func = BINARY_OPERATORS[token]
    lhs = universe.stack.pop
    rhs = universe.to_globals
    catch(:EOF) {
      until stream.stack.empty?
        next_token = parser.parse(stream, rhs)
        p next_token
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
      warn("[Warning] ambiguous rhs for operator `#{token}` w/ lhs `#{lhs}`:  `#{rhs}`. Using `#{rhs.stack.first}` ")
    end
    universe << func.call(lhs, rhs.stack.first, universe, parser)
  end

  def handle_unary_oper(token, stream, universe, parser)
    func = UNARY_OPERS[token]
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
    universe << func.call(rhs.stack.first, universe, parser)
  end

  def handle(token, stream, universe, parser)
    return handle_oper_end(token, universe) if OPER_ENDS.include?(token)
    return handle_unary_oper(token, stream, universe, parser) if UNARY_OPERS.include?(token)
    handle_binary_oper(token, stream, universe, parser)
  end

end
