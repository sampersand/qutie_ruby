class QTError# < QT_Object
  def initialize(context)
    @context = context
  end

  # def qt_to_bool
  #   QT_False::INSTANCE
  # end

  def to_s
    context = @context.to_s.gsub(/\n/, "\n\t")
    cls = self.class.to_s.split("_")[-1]
    msg = message.to_s.gsub(/\n/, "\n\t")
"#{$QT_CONTEXT.stacks.collect(&:to_s).join("\n")}\n\t#{cls}: #{msg}"
end
end
require_relative 'method_missing'
require_relative 'syntax_error'
require_relative 'reached_eof'