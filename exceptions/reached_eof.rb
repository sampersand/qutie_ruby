class QTE_Syntax_EOF < QTE_Syntax
  attr_reader :message
  def initialize( context, message )
    super(context)
    @message = message
  end
end
