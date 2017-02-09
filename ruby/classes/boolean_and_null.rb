require_relative 'default'
require_relative 'text'
class QT_BooleanNull < QT_Object
  def self.get_class(oper)
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
        def qt_eql(right:); QT_BooleanNull::get_class right.is_a? self.class end
      # logic
        def qt_not; QT_BooleanNull::get_class !self.class::VALUE end

end

class QT_True < QT_BooleanNull
  VALUE = true
  INSTANCE = new
end

class QT_False < QT_BooleanNull
  VALUE = false
  INSTANCE = new
end

class QT_Null < QT_BooleanNull
  VALUE = nil
  INSTANCE = new
end
