module Default
  require_relative 'object'

  class QT_Default < QT_Object; end

  module_function
  def next_token!(stream:, **_)
    stream.next
  end
  
  def handle(token, universe, **_)
    universe << QT_Default::from(source: token)
  end
end