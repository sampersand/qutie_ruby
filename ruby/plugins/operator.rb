module Operator
  OPERATORS = { # order matters!
    '<-'  => proc { |l, r, u| OPERATORS['='].(l, r, u) },
    '->'  => proc { |l, r, u| OPERATORS['='].(r, l, u)},

    '**' => proc { |l, r| l.qt_pow(right: r) || r.qt_pow_r(left: l) },
    '*'  => proc { |l, r| l.qt_mul(right: r) || r.qt_mul_r(left: l) },
    '/'  => proc { |l, r| l.qt_div(right: r) || r.qt_div_r(left: l) },
    '%'  => proc { |l, r| l.qt_mod(right: r) || r.qt_mod_r(left: l) },
    '+'  => proc { |l, r| l.qt_add(right: r) || r.qt_add_r(left: l) },
    '-'  => proc { |l, r| l.qt_sub(right: r) || r.qt_sub_r(left: l) },
    '==' => proc { |l, r| l.qt_eql(right: r) || r.qt_eql_r(left: l) },
    '<>' => proc { |l, r| l.qt_neq(right: r) || r.qt_neq_r(left: l) },
    '<=' => proc { |l, r| l.qt_leq(right: r) || r.qt_leq_r(left: l) },
    '>=' => proc { |l, r| l.qt_geq(right: r) || r.qt_geq_r(left: l) },
    '<'  => proc { |l, r| l.qt_lth(right: r) || r.qt_lth_r(left: l) },
    '>'  => proc { |l, r| l.qt_gth(right: r) || r.qt_gth_r(left: l) },

    '||'  => proc { |l, r| l.qt_to_bool.bool_value ? l : r },
    '&&'  => proc { |l, r| l.qt_to_bool.bool_value ? r : l },
    'xor' => proc { |l, r| l ^ r }, # doesnt work

    '='   => proc { |l, r, u| u.locals[l] = r},
    '@0' => proc { |func, args, universe, stream, parser| OPERATORS['@'].(func, args, universe, stream, parser).stack.last },
    '@'  => proc { |func, args, universe, stream, parser|
      if func.respond_to?(:call)
        func.call(args, universe, stream, parser)
      else
        func.qt_call(args: args,
                     universe: universe,
                     stream: stream,
                     parser: parser)
      # elsif func.is_a?(String)
      #   func = func.clone
      #   if args.locals.include?(:'__preprocess') && args.locals[:__preprocess]
      #     PreParser::pre_process!(func)
      #   end
      #   parser.process(input: func, additional_builtins: args.locals)
      # else
      #   begin
      #     args.locals[:__args] = args #somethign here with spawn off
      #     # func.program_stack.push args
      #   rescue NoMethodError
      #     puts "Invalid `@` for `#{func.inspect}` with args `#{args.inspect}`"
      #     exit(1);
      #   end
      #   parser.parse(stream: func, universe: args)
      #   # func.program_stack.pop
      end
    },

    '.L='  => proc { |arg, pos| arg.locals[pos.stack[0]] = pos.stack[1] },
    '.S='  => proc { |arg, pos| arg.stack[pos.stack[0]] = pos.stack[1] },
    '.='  => proc { |arg, pos| 
      OPERATORS[pos.stack[0].is_a?(Numeric) ? '.S=' : '.V='].(arg, pos)
      },
    '.S'  => proc { |arg, pos| arg.qt_index(pos: pos, type: :STACK) },
    '.L'  => proc { |arg, pos| arg.qt_index(pos: pos, type: :LOCALS) },
    '.'  => proc { |arg, pos| arg.qt_index(pos: pos, type: :BOTH) },
  }

  OPER_END = [';', ',']
  # handling the operators
    module_function
    def priority(token, plugin)
      case
      when plugin == Operator
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
        when '.=', '.S=', '.L=' then 6
        when '.', '.S', '.L' then 5
        when  '$', '!', '?' then 1
        else raise "Unknown operator `#{token}`"
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
      when '**' then QT_Number::Math_E
      when '*', '/' then QT_Number::ONE
      when '+', '-' then QT_Number::ZERO
      end
    end

    def handle_oper(token:, stream:, universe:, parser:)
      lhs = universe.pop
      rhs = universe.spawn_new_stack(new_stack: nil)
      token_priority = priority(token, Operator)
      parser.catch_EOF(universe) {
        until stream.stack_empty?
          ntoken = parser.next_token!(stream: stream.clone,
                                      universe: rhs,
                                      parser: parser)
          if ntoken[0] =~ /[-+*\/]/ and ntoken[1] == Operator and rhs.stack_empty?  # this is dangerous
            ntoken = parser.next_token!(stream: stream,
                                        universe: rhs,  
                                        parser: parser)
            rhs << fix_lhs(ntoken[0])
            ntoken[1].handle(token: ntoken[0],
                             stream: stream,
                             universe: rhs,
                             parser: parser)
          else
            break if token_priority <= priority(*ntoken) 
            ntoken = parser.next_token!(stream: stream,
                                        universe: rhs,
                                        parser: parser)
            ntoken[1].handle(token: ntoken[0],
                             stream: stream,
                             universe: rhs,
                             parser: parser) # pretty sure this will bite me...
          end
        end
        nil
      }
      universe.stack.concat(rhs.stack)
      lhs ||= fix_lhs(token)
      rhs = universe.pop
      result = OPERATORS[token].call(lhs, rhs, universe, stream, parser)
      result or raise "Invalid operand types for `#{token}`: `#{lhs.class}` and `#{rhs.class}`"
      universe << result
    end


end










