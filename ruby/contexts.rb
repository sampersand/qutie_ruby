class Context
  NEWL = "\n"
  attr_reader :stream, :file, :orig_line_count
  def initialize(stream, file, context_manager)
    @stream = stream
    @orig_stream = @stream.clone
    @tot_lines = lines_left
    @file = file
    @context_manager = context_manager
    if @context_manager.files.include?(@file)
      @start_line = @context_manager.files[@file].func_current_line
    else
      @start_line = func_current_line
    end
  end

  def lines_left
    @stream.stack.select{ |e| e.text_val == NEWL }.length
  end

  def orig_line_count
    @orig_stream.stack.select{ |e| e.text_val == NEWL }.length
  end

  def file_current_line
    @context_manager.files[@file]
  end
  def func_current_line
    @tot_lines - lines_left + 1
  end

  def to_s
    file = @file.gsub(/\n/, "\n\t")
    line_no = func_current_line
    "#{file}:#{file_current_line}: #{line(line_no)}"
  end

  def line(line_no)
    stream = @orig_stream.clone
    stream << QT_Default.new( :"\n" )
    lines = 1
    line = ''
    catch(:EOF) do
      until lines == line_no
        lines += 1 if NEWL == stream._next.text_val
      end
      line += stream._next.text_val until NEWL == stream._peek.text_val
      true
    end or fail "Couldn't with finding line ##{line_no}"
    line
  end

end

class Contexts
  attr_reader :stacks
  attr_reader :files
  def initialize()
    @stacks = []
    @files = {}
  end

  def start(stream)
    file = `pwd`.chomp
    @stacks << Context.new(stream, file, self)
    @files[file] = @stacks.last.orig_line_count unless @files.include? file
  end

  def stop(expected)
    fail "CONTEXT MISMATCH! expected: #{expected}" unless @stacks.pop.stream.eql?(expected)
  end

  def current
    @stacks.last.clone
  end

  def to_s
    @stacks.collect(&:to_s).join("\n")
  end

end








