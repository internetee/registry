require 'test_helper'

class SettingEntryTest < ActiveSupport::TestCase
  def setup
  end

  def test_fixture_is_valid
    assert setting_entries(:legal_document_is_mandatory).valid?
  end
end
