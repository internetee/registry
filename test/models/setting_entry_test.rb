require 'test_helper'

class SettingEntryTest < ActiveSupport::TestCase
  def setup
    @new_setting = SettingEntry.new(code: 'new_setting', value: 'looks great', format: 'string', group: 'other')
  end

  def test_fixture_is_valid
    assert setting_entries(:legal_document_is_mandatory).valid?
  end

  def test_can_be_retrieved_via_class_method
    setting = setting_entries(:legal_document_is_mandatory)
    assert setting.retrieve, Setting.legal_document_is_mandatory
  end

  def test_can_be_updated_via_class_method
    setting = setting_entries(:legal_document_is_mandatory)
    setting.update(value: 'false')
    setting.reload

    Setting.legal_document_is_mandatory = true
    setting.reload
    assert true, setting.retrieve
  end

  def test_setting_code_is_required
    assert @new_setting.valid?
    @new_setting.code = nil
    assert_not @new_setting.valid?
  end

  def test_setting_code_can_only_include_underscore_and_characters
    assert @new_setting.valid?
    @new_setting.code = 'a b'
    assert_not @new_setting.valid?

    @new_setting.code = 'ab_'
    assert_not @new_setting.valid?

    @new_setting.code = '_ab'
    assert_not @new_setting.valid?

    @new_setting.code = '1_2'
    assert_not @new_setting.valid?

    @new_setting.code = 'a_b'
    assert @new_setting.valid?
  end

  def test_setting_value_can_be_nil
    assert @new_setting.valid?
    @new_setting.value = nil
    assert @new_setting.valid?
  end

  def test_setting_format_is_required
    assert @new_setting.valid?
    @new_setting.format = nil
    assert_not @new_setting.valid?

    @new_setting.format = 'nonexistant'
    assert_not @new_setting.valid?
  end

  def test_setting_group_is_required
    assert @new_setting.valid?
    @new_setting.group = nil
    assert_not @new_setting.valid?

    @new_setting.group = 'random'
    assert @new_setting.valid?
  end

  def test_returns_nil_for_unknown_setting
    assert_nil Setting.unknown_and_definitely_not_saved_setting
  end

  def test_throws_error_if_updating_unknown_setting
    assert_raises ActiveRecord::RecordNotFound do
      Setting.unknown_and_definitely_not_saved_setting = 'hope it fails'
    end
  end

  def test_parses_string_format
    Setting.create(code: 'string_format', value: '1', format: 'string', group: 'random')
    assert Setting.string_format.is_a? String
  end

  def test_parses_integer_format
    Setting.create(code: 'integer_format', value: '1', format: 'integer', group: 'random')
    assert Setting.integer_format.is_a? Integer
  end

  def test_parses_float_format
    Setting.create(code: 'float_format', value: '0.5', format: 'float', group: 'random')
    assert Setting.float_format.is_a? Float
  end

  def test_parses_boolean_format
    Setting.create(code: 'boolean_format', value: 'true', format: 'boolean', group: 'random')
    assert_equal true, Setting.boolean_format

    Setting.boolean_format = 'false'
    assert_equal false, Setting.boolean_format

    Setting.boolean_format = nil
    assert_equal false, Setting.boolean_format
  end

  def test_parses_hash_format
    Setting.create(code: 'hash_format', value: '{"hello": "there"}', format: 'hash', group: 'random')
    assert Setting.hash_format.is_a? Hash
  end

  def test_parses_array_format
    Setting.create(code: 'array_format', value: '[1, 2, 3]', format: 'array', group: 'random')
    assert Setting.array_format.is_a? Array
  end
end
