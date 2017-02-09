class QT_Object
  def self.from(source:) #used when directly instatiating it, not copying, etc
    new(source: source) 
  end

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

  # qt methods

    def qt_add(right:);  end
    def qt_add_r(left:); end

end