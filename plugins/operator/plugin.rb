require_relative 'operator'
module Operators
  # handling the operators
    module_function

    def next_token!(env)
      stream = env.stream
      OPERATORS.find do |oper|
        if oper.name == stream._peek( env, oper.name.length ).source_val
          stream._next( env, oper.name.length )
          true
        end
      end
    end

    def handle(token, env)
      oper = token
      lhs_vars = oper.operands[0].times.collect{ get_lhs(oper, env) }
      rhs_vars = oper.operands[1].times.collect{ get_rhs(oper, env) }
      result = oper.call(lhs_vars, rhs_vars, env)
      # result or fail "Unknown method `#{token}` for `#{lhs_vars}` and `#{rhs_vars}`"
      # result or universe.qt_throw(err: QT_NoMethodError,
      #                             operand: token,
      #                             lhs_vars: lhs_vars,
      #                             rhs_vars: rhs_vars)
      warn("`#{oper}` returned non-QT_Object `#{result.class}`") unless true == result || result.is_a?(QT_Object)
      env.universe << result if result.is_a?(QT_Object)
    end

    def get_lhs(oper, env)
      env.universe.pop || QT_Null::INSTANCE
    end

    def get_rhs(oper, env)
      universe = env.universe
      stream = env.stream
      parser = env.parser
      # rhs = universe.spawn_new_stack(new_stack: universe.stack.clone)
      rhs = universe
      token_priority = oper.priority
      catch(:EOF){
        until stream.stack_empty?(env)
          ntoken = parser.next_token!(env.fork(stream: stream.clone, universe: rhs))
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
            ntoken = parser.next_token!(env.fork(universe: rhs))
            ntoken[1].handle(ntoken[0], env.fork(universe: rhs))
          # end
        end
        nil
      }
      # rhs.stack.shift(universe.stack.length);
      # # p rhs.stack
      # raise "Ambiguous rhs for operator `#{oper}`: #{rhs.stack}" unless rhs.stack.length == 1
      rhs.stack.pop || QT_Null::INSTANCE
    end

    # def fix_lhs(token)
    #   case token
    #   when '**'     then QT_Number::Math_E
    #   when '*', '/' then QT_Number::ONE
    #   when '+', '-' then QT_Number::ZERO
    #   end
    # end
end









