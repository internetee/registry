class EppSession < ActiveRecord::Base
  before_save :marshal_data!

  belongs_to :registrar
  # rubocop: disable Rails/ReadWriteAttribute
  # Turned back to read_attribute, thus in Rails 4
  # there is differences between self[:data] and read_attribute.
  def data
    @data ||= self.class.unmarshal(read_attribute(:data)) || {}
  end
  # rubocop: enable Rails/ReadWriteAttribute

  def [](key)
    data[key.to_sym]
  end

  def []=(key, value)
    data[key.to_sym] = value
    save!
  end

  def marshal_data!
    self.data = self.class.marshal(data)
  end

  class << self
    def marshal(data)
      ::Base64.encode64(Marshal.dump(data)) if data
    end

    def unmarshal(data)
      return data unless data.is_a? String
      Marshal.load(::Base64.decode64(data)) if data
    end
  end
end
