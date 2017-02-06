module BinaryOperator
  module_function
  OPERATORS = { # order matters!

    '<-'  => proc { |l, r, u| OPERATORS['='].(l, r, u) },
    '->'  => proc { |l, r, u| OPERATORS['='].(r, l, u)},

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
    'xor' => proc { |l, r| l ^ r }, # doesnt work

    '='   => proc { |l, r, u| u.locals[l] = r},
    '@$' => proc { |func, args, universe, stream, parser| OPERATORS['@'].(func, args, universe, stream, parser).stack.last },
    '@'  => proc { |func, args, universe, stream, parser|
      if func.respond_to?(:call)
        func.call(args, universe, stream, parser)
      else
        args.locals[:__args] = args.clone #somethign here with spawn off
        func.class::PROGRAM_STACK.unshift args
        parser.parse(stream: func, universe: args)
        func.class::PROGRAM_STACK.shift
      end
      },

    '.V='  => proc { |arg, pos| arg.locals[pos.stack[0]] = pos.stack[1] },
    '.S='  => proc { |arg, pos| arg.stack[pos.stack[0]] = pos.stack[1] },
    '.='  => proc { |arg, pos| 
      OPERATORS[pos.stack[0].is_a?(Numeric) ? '.S=' : '.V='].(arg, pos)
      },
    '.S'  => proc { |arg, pos| arg.stack[pos] },
    '.V'  => proc { |arg, pos| arg.get(pos) },
    '.'  => proc { |arg, pos|
      res = arg.get(pos)
      res.nil?  && pos.is_a?(Integer) ? arg.stack[pos] : res
    },
  }

  OPER_END = [';', ',']

  def priority(token, plugin)
    case
    when plugin == BinaryOperator
      case token
      when *OPER_END then 40
      when '=' then 30
      when '->', '<-' then 29
      when 'or' then 25
      when 'and' then 24
      when '==', '<>', '<=', '>=', '<', '>' then 20
      when '+', '-' then 12
      when '*', '/', '%' then 11
      when '**', '^' then 10
      when '@$', '@' then 7
      when '.=', '.S=', '.V=' then 6
      when '.', '.S', '.V' then 5
      when  '$', '!', '?' then 1
      else raise "Unknown operator #{token}"
      end
    else 0
    end
  end

  def next_token!(stream, _, _)
    OPERATORS.each{ |oper, _| return stream.next!(oper) if stream.peek?(oper) }
    OPER_END.each{  |o_end| return stream.next!(o_end) if stream.peek?(o_end) }
    nil
  end

  def handle(token, stream, universe, parser)
    if OPER_END.include?(token)
      universe.pop! if token == ';'
    else
      handle_oper(token, stream, universe, parser)
    end
  end


  def handle_oper(token, stream, universe, parser)
    lhs = universe.pop!
    catch(:EOF) {
      until stream.stream_empty?
        # vvvv this might get weird if rhs doesnt copy
        break if priority(token, BinaryOperator) <= priority(*parser.next_token(stream, universe)) 
        # ^^^^

        next_token = parser.next_token!(stream, universe)
        next_token[1].handle(next_token[0], stream, universe, parser) # pretty sure this will bite me...
      end
    }

    # rhs = parser.parse!(rhs, universe.spawn_frame!)

    # unless rhs.stack.length == 1
    #   if rhs.stack.empty?
    #     puts("[Error] No rhs for operator `#{token}` w/ lhs `#{lhs}`")
    #     exit!
    #   end
    #   warn("[Warning] ambiguous rhs for operator `#{token}` w/ lhs `#{lhs}`:  `#{rhs}`. Using `#{rhs.stack.first}` ")
    # end
    # universe << OPERATORS[token].(lhs, rhs.stack.first, universe, parser)
    universe << OPERATORS[token].(lhs, universe.pop!, universe, stream, parser)
  end

  # def handle_oper(token, stream, universe, parser)
  #   lhs = universe.pop!
  #   rhs = universe.spawn_frame
  #   catch(:EOF) {
  #     until stream.stream_empty?
  #       # vvvv this might get weird if rhs doesnt copy
  #       break if priority(token, BinaryOperator) <= priority(*parser.next_token(stream, rhs)) 
  #       # ^^^^

  #       next_token = parser.next_token!(stream, rhs)
  #       p next_token # right here it breaks}}
  #       next_token[1].handle(next_token[0], stream, rhs, parser) # pretty sure this will bite me...
  #     end
  #   }

  #   # rhs = parser.parse!(rhs, universe.spawn_frame!)

  #   unless rhs.stack.length == 1
  #     if rhs.stack.empty?
  #       puts("[Error] No rhs for operator `#{token}` w/ lhs `#{lhs}`")
  #       exit!
  #     end
  #     warn("[Warning] ambiguous rhs for operator `#{token}` w/ lhs `#{lhs}`:  `#{rhs}`. Using `#{rhs.stack.first}` ")
  #   end
  #   universe << OPERATORS[token].(lhs, rhs.stack.first, universe, parser)
  # end

end






