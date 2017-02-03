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
parser.add_plugin Parenthesis
# parser.add_plugin Operator
parser.add_plugin Comment
parser.add_plugin Text
# parser.add_plugin Keyword
parser.add_plugin Escape

text = <<End
# 2*3+4
# 2+3*4
# abc = 23 * 34 + 45;
(2+{3-44})*4
End

#abc = 23 * 34 + 45;
#\\#foo?@(a=1,b=2);
#'abc'
#3

res = parser.process(text)
require 'pp'

p res
















