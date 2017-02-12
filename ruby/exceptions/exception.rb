class QTError# < QT_Object
  def initialize(context)
    @context = context
  end

  # def qt_to_bool
  #   QT_False::INSTANCE
  # end

  def to_s
    context = @context.to_s.gsub(/\n/, "\n\t")
    cls = self.class.to_s.gsub(/\n/, "\n\t")
    msg = message.to_s.gsub(/\n/, "\n\t")
# "#{@context.file}: #{@context.current_line}\n#{cls}: #{msg}\n#{@context.current_line}:\t\t#{@context.line( @context.current_line )}"
# "#{cls}:\n#{msg}\nAt #{@context.file}:#{@context.current_line}:  #{@context.line( @context.current_line )}"
"#{cls}:\nAt #{@context.file}:#{@context.current_line}:  #{@context.line( @context.current_line )}\n#{msg}"
end

end
require_relative 'method_missing'
require_relative 'syntax_error'
require_relative 'reached_eof'