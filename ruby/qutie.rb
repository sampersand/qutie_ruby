
require_relative 'parser'
require_relative 'plugins/whitespace'
require_relative 'plugins/parenthesis'
require_relative 'plugins/number'
require_relative 'plugins/binary_operator'
require_relative 'plugins/variable'
require_relative 'plugins/comment'
require_relative 'plugins/text'
require_relative 'plugins/keyword'
require_relative 'plugins/escape'

require_relative 'functions'
require_relative 'constants'
parser = Parser.new
parser.add_plugin Whitespace
parser.add_plugin Comment
parser.add_plugin Number
parser.add_plugin Variable
parser.add_plugin Parenthesis
parser.add_plugin BinaryOperator
parser.add_plugin Keyword
parser.add_plugin Text
parser.add_plugin Escape
parser.add_builtins(Functions::FUNCTIONS)
parser.add_builtins(Constants::CONSTANTS)

ARGV[0] = '/Users/westerhack/code/ruby/qutie/examples/users.qt'
file = ARGV[0] or fail "No file!"
text = open(file, 'r').read
Parser::PreParser::pre_process!(text)

# puts text
res = parser.process(text)

require 'pp'
puts '----[end]----'
res.stack.each_with_index{ |i,j| puts "\t#{j}: #{i.inspect}"}
puts '-------------'
