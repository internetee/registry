RSpec::Matchers.define :alias_attribute do |alias_name, original_name|
  match do |actual|
    actual.class.attribute_alias(alias_name) == original_name.to_s
  end

  failure_message do |actual|
    "expected #{actual.class.name} to alias attribute :#{alias_name} by :#{original_name}"
  end
end
