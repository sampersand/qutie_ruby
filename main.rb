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
parser.add_plugin Parenthesis
parser.add_plugin Number
parser.add_plugin Operator
parser.add_plugin Variable
parser.add_plugin Comment
parser.add_plugin Text
parser.add_plugin Keyword
parser.add_plugin Escape

# text = <<START
# ab=1+2*3-4;$$
# cd=5;$$
# arr=(6,9)!;$$
# foo={ 1 + (a? * 3):0 };$$
# [foo? @ (a=3)!,$ 2,$ 5,$ 8]:1,$
# str='abc';
# START

text = '1*2+3'
text = '2*3+4'
# # a:0:0
# # add={
# #   a? + b?
# # };
# # a=(add?@(a=3, b=4)!)!:0:0
# EOF


res = parser.process(text)
require 'pp'
pp res
p res.knowns
















