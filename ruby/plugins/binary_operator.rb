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

    '|'  => proc { |l, r| l || r },
    'and' => proc { |l, r| l && r },
    'xor' => proc { |l, r| l ^ r }, # doesnt work

    '='   => proc { |l, r, u| u.locals[l] = r},
    '@$' => proc { |func, args, universe, stream, parser| OPERATORS['@'].(func, args, universe, stream, parser).stack.last },
    '@'  => proc { |func, args, universe, stream, parser|
      begin
        if func.respond_to?(:call)
          func.call(args, universe, stream, parser)
        elsif func.is_a?(String)
          parser.process(func, additional_builtins: args.locals)
        else
          args.locals[:__args] = args #somethign here with spawn off
          func.program_stack.push args
          parser.parse(stream: func, universe: args)
          func.program_stack.pop
        end
      rescue NoMethodError
        puts "Invalid `@` for `#{func.inspect}` with args `#{args.inspect}`"
        exit(1);
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
      if arg.is_a?(String)
        arg[pos]
      else
        begin
          res = arg.get(pos)
          res.nil?  && pos.is_a?(Integer) ? arg.stack[pos] : res
        rescue NoMethodError
          puts("Invalid `.` for `#{arg.inspect}` with pos `#{pos.inspect}`")
          exit(1)
        end
      end
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
      when '|' then 25
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

  def fix_lhs(token)
    case token
    when '**' then Math::E
    when '*', '/' then 1.0
    when '+', '-' then 0
    end
  end

  def handle_oper(token, stream, universe, parser)
    lhs = universe.pop!
    rhs = universe.spawn_new_stack(new_stack: nil)
    token_priority = priority(token, BinaryOperator)
    parser.catch_EOF(universe) {
      until stream.stream_empty?
        next_token = parser.next_token(stream, rhs)
        if next_token[0] =~ /[-+*\/]/ and next_token[1] == BinaryOperator and rhs.stack.empty?
          next_token = parser.next_token!(stream, rhs)
          rhs.push!(fix_lhs(next_token[0]))
          # puts rhs, next_token, stream
          next_token[1].handle(next_token[0], stream, rhs, parser)
        else
          break if token_priority <= priority(*next_token) 
          next_token = parser.next_token!(stream, rhs)
          next_token[1].handle(next_token[0], stream, rhs, parser) # pretty sure this will bite me...
        end
      end
      nil
    }
    universe.stack.concat(rhs.stack)
    lhs ||= fix_lhs(token)
    universe << OPERATORS[token].(lhs, universe.pop!, universe, stream, parser)
  end


  # def handle_oper(token, stream, universe, parser)
  #   lhs = universe.pop!
  #   parser.catch_EOF(universe) {
  #     until stream.stream_empty?
  #       break if priority(token, BinaryOperator) <= priority(*parser.next_token(stream, universe)) 
  #       next_token = parser.next_token!(stream, universe)
  #       next_token[1].handle(next_token[0], stream, universe, parser) # pretty sure this will bite me...
  #     end
  #     nil
  #   }
  #   universe << OPERATORS[token].(lhs, universe.pop!, universe, stream, parser)
  # end

end






