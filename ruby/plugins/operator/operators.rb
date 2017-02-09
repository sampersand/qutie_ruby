require_relative 'operator'
module Operators
  # handling the operators
    module_function

    def next_token!(stream:, **_)
      OPERATORS.each{ |oper, _| return stream.next(amnt: oper.length) if stream.peek?(str: oper) }
      nil
    end

    def handle(token:, stream:, universe:, parser:, **_)
      if OPERATORS[token].type == :UNARY_POSTFIX
        handle_unary_postfix(token: token,
                     stream: stream,
                     universe: universe,
                     parser: parser)
      else
        handle_binary(token: token,
                      stream: stream,
                      universe: universe,
                      parser: parser)
      end
    end

    def handle_unary_postfix(token:, stream:, universe:, parser:)
      lhs = universe.pop
      result = OPERATORS[token].call(lhs, universe, stream, parser)
      result or raise "Invalid operand types for `#{token}`: `#{lhs.class}`"
      universe << result
    end

    def fix_lhs(token)
      case token
      when '**'     then QT_Number::Math_E
      when '*', '/' then QT_Number::ONE
      when '+', '-' then QT_Number::ZERO
      end
    end

    def handle_binary(token:, stream:, universe:, parser:)
      lhs = universe.pop
      rhs = universe.spawn_new_stack(new_stack: nil)
      token_priority = OPERATORS[token].priority
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
            break if token_priority <= (OPERATORS.include?(ntoken[0]) && ntoken[1] == Operator ? OPERATORS[ntoken[0]].priority : 0)
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










