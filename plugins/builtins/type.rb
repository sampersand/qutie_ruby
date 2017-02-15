require_relative 'object'
require_relative 'boolean'
class QT_Type < QT_Object
  attr_reader :source
  def initialize(source)
    @source = source
  end
  def to_s
    "<type #{@source}>"
  end
  def hash
    to_s.hash
  end
  def == other
    other.class == self.class && @source == other.source
  end
    # operators
      def qt_eql_l(r, _env)
        QT_Boolean::get( self == r)
      end
      def qt_eql_r(l, _env)
        QT_Boolean::get( l == self)# same thing as qt_eql_l
      end
end


