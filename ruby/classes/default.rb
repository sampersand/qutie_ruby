require_relative 'object'
class QT_Default < QT_Object
  def self.from(source:)
    new(source: source)
  end

  def initialize(source:)
    warn("Source for #{self.class} is not a String, but `#{source.class}`)") unless source.is_a?(String)
    @source = source
  end

  def to_s
    @source.to_s
  end

  def ==(other)
    other.is_a?(QT_Default) && @source == other.source
  end

  def hash
    @source.hash
  end
end
