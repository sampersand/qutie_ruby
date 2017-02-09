module Default
  require_relative 'object'

  class QT_Default < QT_Object; end

  module_function
  def next_token!(stream, _, _)
    stream.next
  end
  
  def handle(token, _, universe, _)
    universe << QT_Default::from(source: token)
  end
end