$GET_VAR_USE_VALUE = false
module GetVar
  module_function

  def next_token!(env)
    Variable.next_token!(env)
  end

  def handle(token, env)
    ntoken = catch(:EOF){ Operators.next_token!(env.clone) } || nil
    if Operators::OPER_DO_NOT_EVAL_PRE.include?(ntoken) || $GET_VAR_USE_VALUE
      env.universe << token
    else
      env.universe << Operators::INDEX_OPER.call( [token], [], env )
    end
  end
end










