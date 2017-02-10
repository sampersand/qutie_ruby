require_relative 'operator'
module Operators
  # handling the operators
    module_function

    def next_token!(stream:, **_)
      OPERATORS.each{ |oper, _| return stream.next(amnt: oper.length) if stream.peek?(str: oper) }
      nil
    end

    def handle(token:, stream:, universe:, parser:, **_)
      # if OPERATORS[token].type == :UNARY_POSTFIX
      #   handle_unary_postfix(token: token,
      #                stream: stream,
      #                universe: universe,
      #                parser: parser)
      # else
      #   handle_binary(token: token,
      #                 stream: stream,
      #                 universe: universe,
      #                 parser: parser)
      # end
      oper = OPERATORS[token] or fail "Unknown operator `#{token}`, but it somehow got passed to handle!"
      lhs_vars = oper.operands[0].times.collect{ get_lhs(universe: universe) }
      rhs_vars = oper.operands[1].times.collect{ get_rhs(token: token,
                                                         universe: universe,
                                                         stream: stream,
                                                         parser: parser) }

      result = oper.call(lhs_vars: lhs_vars,
                         rhs_vars: rhs_vars,
                         universe: universe,
                         stream: stream,
                         parser: parser)
      result or raise "Invalid operand types for `#{token}`: `#{lhs_vars}` and `#{rhs_vars}`"
      warn("`#{token}` returned non-QT_Object `#{result.class}`") unless result == true || result.is_a?(QT_Object)
      universe << result if result.is_a?(QT_Object)
    end

    def get_lhs(universe:)
      universe.pop
    end

    def get_rhs(token:, stream:, universe:, parser:)
      rhs = universe.spawn_new_stack(new_stack: nil)
      token_priority = OPERATORS[token].priority
      catch(:EOF){
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
            break if token_priority <= (OPERATORS.include?(ntoken[0]) && ntoken[1] == Operators ?
                                          OPERATORS[ntoken[0]].priority :
                                          0)
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
      raise "Ambiguous rhs for operator `#{token}`: #{rhs.stack}" unless rhs.stack.length == 1
      rhs.stack[0]
    end

    def handle_unary_postfix(token:, stream:, universe:, parser:)
      if token == ';'
        get_lhs(universe: universe) # and ignore
        return
      end
      lhs = get_lhs(token: token,
                    stream: stream,
                    universe: universe,
                    parser: parser)
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
      lhs = get_lhs(token: token,
                    stream: stream,
                    universe: universe,
                    parser: parser)
      rhs = get_rhs(token: token,
                    stream: stream,
                    universe: universe,
                    parser: parser)
      universe.stack.concat(rhs)
      lhs ||= fix_lhs(token)
      rhs = universe.pop
      result = OPERATORS[token].call(lhs, rhs, universe, stream, parser) or raise "Invalid operand types for `#{token}`: `#{lhs.class}` and `#{rhs.class}`"
      universe << result
    end


end










