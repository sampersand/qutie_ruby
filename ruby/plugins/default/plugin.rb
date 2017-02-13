require_relative 'default'

module Default

  module_function
  def next_token!(environment)
    environment.stream._next
  end
  
  def handle(token, environment)
    environment.universe << token
  end
end