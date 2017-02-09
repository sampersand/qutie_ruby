require_relative 'classes/boolean_and_null'


module Constants

  CONSTANTS = {
    true: QT_Boolean::TRUE,
    false: QT_Boolean::FALSE,
    nil: QT_Null::NULL,
    null: QT_Null::NULL,
    none: QT_Null::NULL,
    math_e: QT_Number::E,
    math_pi: QT_Number::PI,
  }
end
