module Default
  require_relative 'QT_Object'
  class QT_Misc
    def initialize(object)
      @object = object
    end
  end

  module_function
  def next_token!(stream, _, _)
    stream.next
  end
  def handle(token, _, universe, _)
    universe << QT_Misc.new(token)
  end
end