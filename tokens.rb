require_relative 'stream'
class Tokens < Array

  attr_reader :parens
  attr_reader :knowns

  def initialize(body: nil, parens: nil, knowns: nil)
    super()
    concat body if body
    @parens = parens || [nil, nil]
    @knowns = knowns || {}
  end

  def inspect
    res = join.strip
    res = "#{@parens[0]} #{res} #{@parens[1]}" unless @parens.none?
    "[#{res}] <#{@knowns}>"
  end

  def to_stream
    Stream.new(self + ["\n"])
  end

  def +(other)
    self.class.new(body: super, knowns: @knowns.clone)
  end
  def clone
    self.class.new(body: super, parens: @parens.clone, knowns: @knowns.clone)
  end

  def clone_knowns
    self.class.new(knowns: @knowns.clone)
  end

  def merge!(other)
    raise unless other.is_a?(Tokens)
    @knowns.update(other.knowns)
    concat other
  end

  def merge(other)
    clone.merge!(other)
  end
end