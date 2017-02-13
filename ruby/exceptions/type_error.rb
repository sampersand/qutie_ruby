class QTE_Type < QTE
  attr_reader :message
  def initialize( context, message )
    super(context)
    @message = message
  end
end
