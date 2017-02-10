require_relative 'default'

module Default

  module_function
  def next_token!(stream:, **_)
    stream.next
  end
  
  def handle(token:, universe:, **_)
    universe << QT_Default::from(source: token)
  end
end