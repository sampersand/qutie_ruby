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

    '||'  => proc { |l, r| l || r },
    '&&' => proc { |l, r| l && r },
    'xor' => proc { |l, r| l ^ r }, # doesnt work

    '='   => proc { |l, r, u| u.locals[l] = r},
    '@0' => proc { |func, args, universe, stream, parser| OPERATORS['@'].(func, args, universe, stream, parser).stack.last },
    '@'  => proc { |func, args, universe, stream, parser|
      if func.respond_to?(:call)
        func.call(args, universe, stream, parser)
      elsif func.is_a?(String)
        func = func.clone
        if args.locals.include?(:'__preprocess') && args.locals[:__preprocess]
          PreParser::pre_process!(func)
        end
        parser.process(input: func, additional_builtins: args.locals)
      else
        begin
          args.locals[:__args] = args #somethign here with spawn off
          # func.program_stack.push args
        rescue NoMethodError
          puts "Invalid `@` for `#{func.inspect}` with args `#{args.inspect}`"
          exit(1);
        end
        parser.parse(stream: func, universe: args)
        # func.program_stack.pop
      end
    },

    '.V='  => proc { |arg, pos| arg.locals[pos.stack[0]] = pos.stack[1] },
    '.S='  => proc { |arg, pos| arg.stack[pos.stack[0]] = pos.stack[1] },
    '.='  => proc { |arg, pos| 
      OPERATORS[pos.stack[0].is_a?(Numeric) ? '.S=' : '.V='].(arg, pos)
      },
    '.S'  => proc { |arg, pos| arg.stack[pos] },
    '.V'  => proc { |arg, pos| arg.locals[pos] },
    '.'  => proc { |arg, pos|
      STDERR.puts("Invalid `.` for `#{arg.inspect}` with pos `#{pos.inspect}`") unless arg.respond_to?(:[])
      arg[pos]
    },
  }

  OPER_END = [';', ',']

  def priority(token, plugin)
    case
    when plugin == BinaryOperator
      case token
      when *OPER_END then 40
      when '=' then 30
      when '->', '<-' then 30
      when '||' then 25
      when '&&' then 24
      when '==', '<>', '<=', '>=', '<', '>' then 20
      when '+', '-' then 12
      when '*', '/', '%' then 11
      when '**', '^' then 10
      when '@0', '@' then 7
      when '.=', '.S=', '.V=' then 6
      when '.', '.S', '.V' then 5
      when  '$', '!', '?' then 1
      else raise "Unknown operator #{token}"
      end
    else 0
    end
  end

  def next_token!(stream:, **_)
    OPERATORS.each{ |oper, _| return stream.next(amnt: oper.length) if stream.peek?(str: oper) }
    OPER_END.each{  |o_end| return stream.next(amnt: o_end.length) if stream.peek?(str: o_end) }
    nil
  end

  def handle(token:, stream:, universe:, parser:, **_)
    if OPER_END.include?(token)
      universe.pop if token == ';'
    else
      handle_oper(token: token,
                  stream: stream,
                  universe: universe,
                  parser: parser)
    end
  end

  def fix_lhs(token)
    case token
    when '**' then Math::E
    when '*', '/' then 1.0
    when '+', '-' then 0
    end
  end

  def handle_oper(token:, stream:, universe:, parser:)
    lhs = universe.pop
    rhs = universe.spawn_new_stack(new_stack: nil)
    token_priority = priority(token, BinaryOperator)
    parser.catch_EOF(universe) {
      until stream.stack_empty?
        ntoken = parser.next_token!(stream: stream.clone,
                                    universe: rhs,
                                    parser: parser)
        if ntoken[0] =~ /[-+*\/]/ and ntoken[1] == BinaryOperator and rhs.stack_empty?
          ntoken = parser.next_token!(stream: stream,
                                      universe: rhs,
                                      parser: parser)
          rhs << fix_lhs(ntoken[0])
          ntoken[1].handle(ntoken[0], stream, rhs, parser)
        else
          break if token_priority <= priority(*ntoken) 
          ntoken = parser.next_token!(stream: stream,
                                      universe: rhs,
                                      parser: parser)
          ntoken[1].handle(ntoken[0], stream, rhs, parser) # pretty sure this will bite me...
        end
      end
      nil
    }
    universe.stack.concat(rhs.stack)
    lhs ||= fix_lhs(token)
    universe << OPERATORS[token].(lhs, universe.pop, universe, stream, parser)
  end


  # def handle_oper(token, stream, universe, parser)
  #   lhs = universe.pop
  #   parser.catch_EOF(universe) {
  #     until stream.stack_empty?
  #       break if priority(token, BinaryOperator) <= priority(*parser.next_token(stream, universe)) 
  #       next_token = parser.next_token!(stream, universe)
  #       next_token[1].handle(next_token[0], stream, universe, parser) # pretty sure this will bite me...
  #     end
  #     nil
  #   }
  #   universe << OPERATORS[token].(lhs, universe.pop, universe, stream, parser)
  # end

end






