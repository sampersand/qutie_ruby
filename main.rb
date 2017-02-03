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
parser.add_plugin Operator
parser.add_plugin Comment
parser.add_plugin Text
parser.add_plugin Keyword
parser.add_plugin Escape

text = <<End
a=(2+3);
a?$

# 1
# (2 + 3, 6, 7)!
# 4
# 5



End
# # 4 + 3 * 2, 4 + 4
# # (a=3, b=4)


# # add = {
# #   a? + b?
# # };
# # add? @ (a=3,b=4);;;
# # (a=3; b=4;)!
# End

#abc = 23 * 34 + 45;
#\\#foo?@(a=1,b=2);
#'abc'
#3

res = parser.process(text)
require 'pp'

p res
















