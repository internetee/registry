require 'test_helper'
require 'xsd/util'

class XsdUtilTest < ActiveSupport::TestCase
  def test_single_part_name
    version = Xsd::Util.call(schema_path: 'test/fixtures/files/schemas', for_prefix: 'abcde')

    assert_equal 'abcde-1.2.xsd', version
  end

  def test_double_part_name
    version = Xsd::Util.call(schema_path: 'test/fixtures/files/schemas', for_prefix: 'abcde-fghij')

    assert_equal 'abcde-fghij-1.3.xsd', version
  end
end
