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
        def qt_to_bool(_env); QT_False::INSTANCE end

      # operators
        def qt_eql_l(r, _env)
          QT_Boolean::get( r.class == self.class )
        end
        def qt_eql_r(l, _env)
          QT_Boolean::get( self.class == l.class )# same thing as qt_eql_l
        end
        # def qt_sub_l(right, env) right.qt_neg(env) end
        # def qt_add_l(right, env) right.qt_pos(env) end
  INSTANCE = new
end


