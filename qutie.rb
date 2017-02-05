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
require_relative 'plugins/keyword_functions'
require_relative 'plugins/boolean'

parser = Parser.new
parser.add_plugin Whitespace
parser.add_plugin Number
parser.add_plugin Variable
parser.add_plugin Parenthesis
parser.add_plugin Comment
parser.add_plugin Keyword
parser.add_plugin Operator
parser.add_plugin Escape
parser.add_plugin KeywordFunctions
parser.add_plugin Text
parser.add_plugin Boolean

file = ARGV[0] or fail "No file!"
text = open(file, 'r').read
parser.pre_process!(text, show_text: false)
require_relative 'functions'
res = parser.process(text, default_locals: Functions::FUNCTIONS)
require 'pp'

puts '----[end]----'
res.stack.each_with_index{ |i,j| puts "\t#{j}: #{i.inspect}"}
p res















