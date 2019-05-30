class Counter
  def initialize(value = 0)
    @value = value
  end
  attr_accessor :value
  def method_missing(*args, &blk)
    @value.send(*args, &blk)
  end

  def to_s
    @value.to_s
  end

  def now
    @value
  end

  # pre-increment ".+" when x not present
  def next(x = 1)
    @value += x
  end

  def prev(x = 1)
    @value -= x
  end
end