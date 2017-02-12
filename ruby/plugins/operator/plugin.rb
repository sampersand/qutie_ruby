require_relative 'operator'
module Operators
  # handling the operators
    module_function

    def next_token!(stream:, **_)
      OPERATORS.find do |oper, _|
        if oper.name == stream._peek( oper.name.length ).source_val
          stream._next( oper.name.length )
          true
        end
      end
    end

    def handle(token:, stream:, universe:, parser:, **_)
      oper = token
      lhs_vars = oper.operands[0].times.collect{ get_lhs(universe: universe) }
      rhs_vars = oper.operands[1].times.collect{ get_rhs(oper: oper,
                                                         universe: universe,
                                                         stream: stream,
                                                         parser: parser) }
      result = oper.call(lhs_vars: lhs_vars,
                         rhs_vars: rhs_vars,
                         universe: universe,
                         stream: stream,
                         parser: parser)
      result or fail "Unknown method `#{token}` for `#{lhs_vars}` and `#{rhs_vars}`"
      # result or universe.qt_throw(err: QT_NoMethodError,
      #                             operand: token,
      #                             lhs_vars: lhs_vars,
      #                             rhs_vars: rhs_vars)
      warn("`#{token}` returned non-QT_Object `#{result.class}`") unless result == true || result.is_a?(QT_Object)
      universe << result if result.is_a?(QT_Object)
    end

    def get_lhs(universe:)
      universe.pop
    end

    def get_rhs(oper:, stream:, universe:, parser:)
      rhs = universe.spawn_new_stack(new_stack: nil)
      token_priority = oper.priority
      catch(:EOF){
        until stream.stack_empty?
          ntoken = parser.next_token!(stream: stream.clone,
                                      universe: rhs,
                                      parser: parser)
          # if ntoken[0] =~ /[-+*\/]/ and ntoken[1] == Operator and rhs.stack_empty?  # this is dangerous
          #   ntoken = parser.next_token!(stream: stream,
          #                               universe: rhs,  
          #                               parser: parser)
          #   rhs << fix_lhs(ntoken[0])
          #   ntoken[1].handle(token: ntoken[0],
          #                    stream: stream,
          #                    universe: rhs,
          #                    parser: parser)
          # else
            break if token_priority <= ( ntoken[0].is_a?(QT_Operator) ? ntoken[0].priority : 0 )
            ntoken = parser.next_token!(stream: stream,
                                        universe: rhs,
                                        parser: parser)
            ntoken[1].handle(token: ntoken[0],
                             stream: stream,
                             universe: rhs,
                             parser: parser) # pretty sure this will bite me...
          # end
        end
        nil
      }
      raise "Ambiguous rhs for operator `#{token}`: #{rhs.stack}" unless rhs.stack.length == 1
      rhs.stack[0]
    end

    # def fix_lhs(token)
    #   case token
    #   when '**'     then QT_Number::Math_E
    #   when '*', '/' then QT_Number::ONE
    #   when '+', '-' then QT_Number::ZERO
    #   end
    # end
end










