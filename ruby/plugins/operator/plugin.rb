require_relative 'operator'
module Operators
  # handling the operators
    module_function

    def next_token!(environment)
      stream = environment.stream
      OPERATORS.find do |oper|
        if oper.name == stream._peek( oper.name.length ).source_val
          stream._next( oper.name.length )
          true
        end
      end
    end

    def handle(token, environment)
      oper = token
      lhs_vars = oper.operands[0].times.collect{ get_lhs(oper, environment) }
      rhs_vars = oper.operands[1].times.collect{ get_rhs(oper, environment) }
      result = oper.call(lhs_vars, rhs_vars, environment)
      # result or fail "Unknown method `#{token}` for `#{lhs_vars}` and `#{rhs_vars}`"
      # result or universe.qt_throw(err: QT_NoMethodError,
      #                             operand: token,
      #                             lhs_vars: lhs_vars,
      #                             rhs_vars: rhs_vars)
      warn("`#{oper}` returned non-QT_Object `#{result.class}`") unless true == result || result.is_a?(QT_Object)
      environment.universe << result if result.is_a?(QT_Object)
    end

    def get_lhs(oper, environment)
      environment.universe.pop
    end

    def get_rhs(oper, environment)
      universe = environment.universe
      stream = environment.stream
      parser = environment.parser
      rhs = universe.spawn_new_stack(new_stack: nil)
      token_priority = oper.priority
      catch(:EOF){
        until stream.stack_empty?
          ntoken = parser.next_token!(environment.fork(stream: stream.clone, universe: rhs))
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
            ntoken = parser.next_token!(environment.fork(universe: rhs))
            ntoken[1].handle(ntoken[0], environment.fork(universe: rhs))
          # end
        end
        nil
      }
      raise "Ambiguous rhs for operator `#{oper}`: #{rhs.stack}" unless rhs.stack.length == 1
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










