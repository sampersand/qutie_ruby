require_relative 'parser'
require_relative 'plugins/whitespace'
require_relative 'plugins/parenthesis'
require_relative 'plugins/number'
require_relative 'plugins/operator'
require_relative 'plugins/variable'
require_relative 'plugins/comment'
require_relative 'plugins/text'
require_relative 'plugins/keyword'
require_relative 'plugins/escape'

parser = Parser.new
parser.add_plugin Whitespace
parser.add_plugin Number
parser.add_plugin Variable
# parser.add_plugin Parenthesis
# parser.add_plugin Operator
parser.add_plugin Comment
parser.add_plugin Text
# parser.add_plugin Keyword
parser.add_plugin Escape

text = <<End
#abc = 23 * 34 + 45;
#\\#foo?@(a=1,b=2);
#'abc'
#3
2+3*4,
End

res = parser.process(text)
require 'pp'
puts res
p res
















