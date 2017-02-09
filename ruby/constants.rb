require_relative 'classes/boolean'

module Constants
  class QT_Boolean
    class QT_Boolean_True < QT_Boolean

    end
    class QT_Boolean_False < QT_Boolean

    end
    class QT_Boolean_Null < QT_Boolean

    end

    TRUE = QT_Boolean_True.new
    FALSE = QT_Boolean_FALSE.new
    NULL = QT_Boolean_NULL.new
  end

  CONSTANTS = {
    true: QT_Boolean::TRUE,
    false: QT_Boolean::FALSE,
    nil: QT_Boolean::NULL,
    null: QT_Boolean::NULL,
    none: QT_Boolean::NULL
  }
end
