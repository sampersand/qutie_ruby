require_relative 'object'
class QT_Boolean < QT_Object
  def self.get(val)
    (val.nil? ? QT_Null : val ? QT_True : QT_False)::INSTANCE
  end

  def to_s
    self.class::VALUE.inspect
  end

  def bool_val
    self.class::VALUE
  end

  # qt methods
    # methods
      def qt_get(pos, env, type:)
        if pos == QT_Variable.new( :not )
          qt_not(env)
        end
      end
    # operators
      # conversion
        def qt_to_bool(_env); self end

      # operators 
        def qt_eql(right, _env); QT_Boolean::get right.is_a? self.class end
      # logic
        def qt_not(_env); QT_Boolean::get !self.class::VALUE end
end

class QT_True < QT_Boolean
  VALUE = true
  INSTANCE = new
end

class QT_False < QT_Boolean
  VALUE = false
  INSTANCE = new
end








