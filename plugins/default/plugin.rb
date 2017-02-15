require_relative 'default'

module Default

  module_function
  def next_token!(env)
    env.stream._next(env)
  end
  
  def handle(token, env)
    env.universe << token
  end
end