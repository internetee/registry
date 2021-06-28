require 'test_helper'
require 'xsd/schema'

class XsdSchemaTest < ActiveSupport::TestCase
  def setup
    @schema_path = 'test/fixtures/files/schemas'
    super
  end

  def test_single_part_name
    filename = Xsd::Schema.filename(schema_path: @schema_path, for_prefix: 'abcde', for_version: '1.2')

    assert_equal Xsd::Schema::BASE_URL + 'abcde-1.2.xsd', filename
  end

  def test_double_part_name
    filename = Xsd::Schema.filename(schema_path: @schema_path, for_prefix: 'abcde-fghij', for_version: '1.3')

    assert_equal Xsd::Schema::BASE_URL + 'abcde-fghij-1.3.xsd', filename
  end
end
