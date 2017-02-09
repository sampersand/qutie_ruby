require_relative 'default'
require_relative 'text'
class QT_Boolean < QT_Object
  def self.get(oper)
    (oper ? QT_True : QT_False)::INSTANCE
  end

  def to_s
    self.class::VALUE.inspect
  end

  # qt methods
    # operators
      # conversion
        def qt_to_text; QT_Text.new(text_val: to_s) end
        def qt_to_bool; self end

      # operators 
        def qt_eql(right:); QT_Boolean::get right.is_a? self.class end
      # logic
        def qt_not; QT_Boolean::get !self.class::VALUE end

end

class QT_True < QT_Boolean
  VALUE = true
  INSTANCE = new
end

class QT_False < QT_Boolean
  VALUE = false
  INSTANCE = new
end

class QT_Null < QT_Boolean
  VALUE = nil
  INSTANCE = new
end
