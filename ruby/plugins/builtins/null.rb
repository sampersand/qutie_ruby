require_relative 'object'
require_relative 'boolean'
class QT_Null < QT_Object
  def to_s
    'null'
  end

  # qt methods
    # methods
      def qt_get(pos:, type:)
        if pos == QT_Variable::from(source: 'not')
          qt_not
        end
      end
    # operators
      # conversion
        def qt_to_text; QT_Text.new(text_val: to_s) end
        def qt_to_bool; QT_False::INSTANCE end

      # operators 
        def qt_equals(right); right.class == self.class end
      # logic
        def qt_not; QT_True::INSTANCE end
  INSTANCE = new
end

