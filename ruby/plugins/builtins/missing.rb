require_relative 'object'
require_relative 'boolean'
class QT_Missing < QT_Object
  def to_s
    'missing'
  end

  # qt methods
    def _missing?
      true
    end
    # operators
      # conversion
        def qt_to_bool; QT_False::INSTANCE end

      # operators
        def qt_eql_l(r)
          QT_Boolean::get( r.class == self.class )
        end
        def qt_eql_r(l)
          QT_Boolean::get( self.class == l.class )# same thing as qt_eql_l
        end

  INSTANCE = new
end

