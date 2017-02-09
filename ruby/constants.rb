require_relative 'plugins/object'

module Constants
  class QT_Boolean < QT_Object
    class QT_Boolean_True < QT_Boolean
    end
    class QT_Boolean_False < QT_Boolean

    end
    class QT_Boolean_Null < QT_Boolean

    end

    TRUE = QT_Boolean_True::from(source: 'true')
    FALSE = QT_Boolean_False::from(source: 'false')
    NULL = QT_Boolean_Null::from(source: 'null')
  end

  CONSTANTS = {
    true: QT_Boolean::TRUE,
    false: QT_Boolean::FALSE,
    nil: QT_Boolean::NULL,
    null: QT_Boolean::NULL,
    none: QT_Boolean::NULL
  }
end
