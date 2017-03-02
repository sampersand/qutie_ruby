require_relative 'operator'
module Operators
  # handling the operators
    module_function

    def next_token(env)
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
      assert_is_a(oper, QT_Operator, 'oper (aka token)')
      assert_is_a(env, Environment, 'oper (aka token)')
      lhs_vars = oper.operands[0].times.collect{ get_lhs(oper, env) }
      rhs_vars = oper.operands[1].times.collect{ get_rhs(oper, env) }
      assert_is_a(lhs_vars, Array, 'lhs_vars')
      assert_is_a(rhs_vars, Array, 'rhs_vars')
      lhs_vars.each_with_index{ |e, i| assert_is_a(e, QT_Object, "lhs_vars[#{i}]") }
      rhs_vars.each_with_index{ |e, i| assert_is_a(e, QT_Object, "rhs_vars[#{i}]") }
      result = oper.call(lhs_vars, rhs_vars, env)
      unless result == true
        assert_is_a(result, QT_Object, 'result')
        env.universe << result if result.is_a?(QT_Object)
      end
    end

    def get_lhs(oper, env)
      env.universe.pop || QT_Null::INSTANCE
    end

    def get_rhs(oper, env)
      universe = env.universe
      stream = env.stream
      parser = env.parser
      assert_is_a(universe, QT_Universe, 'env.universe')
      assert_is_a(stream, QT_Universe, 'env.stream')
      assert_is_a(parser, Parser, 'env.parser')
      rhs = universe.spawn_new_stack(new_stack: universe.stack.clone)
      assert_is_a(rhs, QT_Universe, 'rhs')
      # rhs = universe
      token_priority = oper.priority
      catch(:EOF){
        until stream.stack_empty?(env)
          ntoken = parser.next_token(env.fork(stream: stream.clone, universe: rhs))
          
          assert_is_a(ntoken, Array, 'ntoken (aka parser.next_token)')
          assert_is_a(ntoken[0], QT_Object, 'ntoken[0] (the token)')
          
          break if token_priority <= ( ntoken[0].is_a?(QT_Operator) ? ntoken[0].priority : 0 )
          assert_respond_to(ntoken[1], :handle, 'ntoken[1] (the handle)')
          ntoken = parser.next_token(env.fork(universe: rhs))

          assert_is_a(ntoken[0], QT_Object, 'ntoken[0] (the token)')
          assert_respond_to(ntoken[1], :handle, 'ntoken[1] (the handle)')
          ntoken[1].handle(ntoken[0], env.fork(universe: rhs))
        end
        nil
      }
      rhs.stack.pop || QT_Null::INSTANCE
    end
end









