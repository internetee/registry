class Hash
  def select_keys(*args)
    select { |k, _| args.include?(k) }.map { |_k, v| v }
  end
end
