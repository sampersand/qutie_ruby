class QT_MethodMissingError < QT_Object
  def initialize( method, caller_, args, line_no:, file_name: )
    @method = method
    @caller = caller_
    @args = args
    @line_no = line_no
    @file_name = file_name
  end
  
end