class QT_Boolean < QT_Object
    TRUE = QT_Boolean::from(source: 'true')
    FALSE = QT_Boolean::from(source: 'false')
  def qt_to_text
    Text::QT_Text.new(text_val: to_s)
  end
end

class QT_Null < QT_Object
  NULL = QT_Null.new
end
