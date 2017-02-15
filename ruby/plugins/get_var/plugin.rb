module GetVar
  module_function

  def next_token!(env)
    Variable.next_token!(env)
  end

  def handle(token, env)
    ntoken = catch(:EOF){ Operators.next_token!(env.clone)} || []
    p env.stream
    if ntoken == Operators::EQL_OPER
      env.universe << token
    else
      # env.universe << Operators::INDEX_OPER.call( [token], [], env )
      # env.universe << Operators::INDEX_OPER.call( [token], [], env )
    end
  end
end










