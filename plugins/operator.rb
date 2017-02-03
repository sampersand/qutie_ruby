module Operator
  module_function
  OPERATOR_FUNCTIONS = {
    '**' => proc { |l, r| l ** r},
    '*'  => proc { |l, r| l *  r},
    '/'  => proc { |l, r| l /  r},
    '%'  => proc { |l, r| l %  r},
    '+'  => proc { |l, r| l +  r},
    '-'  => proc { |l, r| l -  r},
    '='  => proc { |l, r, t| t.knowns[l] = r},
    '@'  => proc { |func, args, tokens, parser|
      parser.parse(func.to_stream, tokens.clone_knowns.merge(args.clone_knowns))#.last
    },
    ':='  => proc { |func, args, tokens, parser|
      func = parser.parse(func.to_stream, tokens.clone_knowns)
      args = parser.parse(args.to_stream, tokens.clone_knowns)
      pos = args[0]
      val = args[1]
      if pos.is_a?(Integer)
        func[pos] = val
      else
        func.knowns[pos] = val
      end
    },
    ':'  => proc { |func, pos, tokens, parser|
      func = parser.parse(func.to_stream, tokens.clone_knowns)
      func[pos]
    },
  }
  OPERATORS = OPERATOR_FUNCTIONS.keys
  OPER_END = '|'
  def priority(token)
    case token
    when OPER_END then 0
    when '=' then 30
    when '+', '-' then 19
    when '*', '/', '%' then 18
    when '**' then 17
    when '-' then 10
    when '@' then 5
    when ':', ':=' then 4
    when  '$', '!', '?' then 1
    else 0
    end
  end
  def parse_oper(stream, tokens, parser)
    oper = OPERATORS.each.find{ |oper| oper == stream.peek(oper.length) }
    return unless oper

    func = OPERATOR_FUNCTIONS[stream.next oper.length]
    lhs = tokens.pop
    
    rhs = tokens.clone_knowns
    until priority(oper) <= priority(rhs.last) || stream.empty?
      p stream, rhs
      parser.next_token(stream, rhs)
      if OPER_END == rhs.last
        last = rhs.pop
        stream.feed last
        break
      end
    end
    p '--'
    warn("[Warning] ambiguous rhs for operator `#{oper}` #{rhs}. Using `#{rhs.first}` ") unless rhs.length == 1
    tokens.push func.call(lhs, rhs.first, tokens, parser)
    true
  end
  def parse_break(stream, tokens, parser)
    case stream.peek
    when ';'
      stream.next
      stream.feed *[OPER_END, '$', '$']
      :retry
    when ','
      stream.next
      stream.feed *[OPER_END, '$']
      :retry
    else
      false
    end
  end
  def parse(stream, tokens, parser)
    parse_oper(stream, tokens, parser) ||
    parse_break(stream, tokens, parser)
  end

end






















