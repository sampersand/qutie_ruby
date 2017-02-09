require_relative 'classes/boolean'

module Constants
  CONSTANTS = {
    true: QT_Boolean::TRUE,
    false: QT_Boolean::FALSE,
    nil: QT_Boolean::NULL,
    null: QT_Boolean::NULL,
    none: QT_Boolean::NULL
  }
end
