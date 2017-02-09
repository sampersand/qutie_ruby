class QT_Object
  def self.from(source:) #used when directly instatiating it, not copying, etc
    new 
  end

  def inspect
    "#{self.class}(#{to_s})"
  end

  def to_s
    ''
  end

  # qt methods

    def qt_add(right:);  end
    def qt_add_r(left:); end

end