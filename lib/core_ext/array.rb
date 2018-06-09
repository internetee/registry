class Array
  def include_any?(*args)
    (self & args).any?
  end
end