class QTError_Syntax_EOF < QTError_Syntax
  attr_reader :message
  def initialize( context, message )
    super(context)
    @message = message
  end
end
