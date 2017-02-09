require_relative 'plugins/object'
require_relative 'plugins/number'

module Constants
  class QT_Boolean < QT_Object
    # consts
      TRUE = QT_Boolean::from(source: 'true')
      FALSE = QT_Boolean::from(source: 'false')
    def qt_to_text
      Text::QT_Text.new(text_val: to_s)
    end
  end

  class QT_Null < QT_Object
    NULL = QT_Null.new
  end

  CONSTANTS = {
    true: QT_Boolean::TRUE,
    false: QT_Boolean::FALSE,
    nil: QT_Null::NULL,
    null: QT_Null::NULL,
    none: QT_Null::NULL,
    math_e: Number::QT_Number::E,
    math_pi: Number::QT_Number::PI,
  }
end
