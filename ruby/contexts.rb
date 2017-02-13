class Context
  NEWL = "\n"
  attr_accessor :stream, :file, :tot_lines, :start_line_no

  def initialize(stream, file, context_manager, univ, start_line_no=nil)
    @context_manager = context_manager
    @stream = stream
    @file = file
    @tot_lines = lines_left
    @orig_stream = @stream.clone
    @univ = univ
    @start_line_no = univ.__start_line_no

  end

  def lines_left
    @stream.stack.select{ |e| e.text_val == NEWL }.length
  end

  def file_line
    @start_line_no +  line_no
  end

  def line_no
    @tot_lines - lines_left
  end

  def to_s
    file = @file.gsub(/\n/, "\n\t")
    "#{file}:#{file_line+1}: #{current_line}"
  end

  def current_line
    get_line( line_no )
  end

  def get_line(line_no)
    stream = @orig_stream.clone
    stream << QT_Default.new( :"\n" )
    lines = 0
    line = ''
    catch(:EOF) do
      until lines == line_no
        lines += 1 if NEWL == stream._next(nil).text_val
      end
      line += stream._next(nil).text_val until NEWL == stream._peek(nil).text_val
      true
    end or fail "Couldn't with finding line ##{line_no}"
    line
  end

  def clone
    self.class.new(@stream.clone, @file.clone, @context_manager.clone, @univ.clone)
  end

end

class Contexts
  attr_reader :stacks
  attr_reader :files
  def initialize()
    @stacks = []
    @files = {}
  end

  def start(stream, univ)
    file = `pwd`.chomp
    @stacks << Context.new(stream, file, self, univ)
  end

  def stop(expected)
    fail "CONTEXT MISMATCH! expected: #{expected}" unless @stacks.pop.stream.eql?(expected)
  end

  def current
    @stacks.last
  end

  def to_s
    @stacks.collect(&:to_s).join("\n")
  end

end










