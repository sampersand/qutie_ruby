class QT_Object
  def initialize(source:)
    warn("Source for #{self.class} is not a String, but `#{source.class}`)") unless source.is_a?(String)
    @source = source
  end

  def inspect
    "#{self.class}(#{@source})"
  end

  def to_s
    @source.to_s
  end

end