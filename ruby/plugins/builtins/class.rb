require_relative 'object'
require_relative 'boolean'
class QT_Class < QT_Object
  def initialize(source_class)
    @source = source_class
  end
  def to_s
    "<type #{@source}>"
  end
end


