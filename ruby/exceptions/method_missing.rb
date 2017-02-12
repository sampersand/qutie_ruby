class QTError_MethodMissing < QTError
  def initialize( context, method_, caller_, args )
    super(context)
    @method = method_
    @caller = caller_
    @args = args
  end

  def message
    "Unknown method `#{@method}` for `#{@caller.inspect}` with args `#{@args.inspect}`"
  end

end