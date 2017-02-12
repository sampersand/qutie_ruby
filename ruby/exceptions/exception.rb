class QT_Exception < QT_Object

  def qt_to_bool
    QT_False::INSTANCE
  end
end
require_relative 'method_missing'