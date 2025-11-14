require 'test_helper'

class BusinessRegistry::DomainNameGeneratorServiceTest < ActiveSupport::TestCase
  test "should generate variants for simple name" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company")
    assert_includes variants, "testcompany.test"
    assert_includes variants, "test-company.test"
  end

  test "should remove legal form from domain name" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company OÜ")
    assert_includes variants, "testcompany.test"
    assert_includes variants, "test-company.test"
  end

  test "should handle different legal forms" do
    legal_forms = %w[AS OU FIE OÜ MTÜ]
    legal_forms.each do |form|
      variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company #{form}")
      assert_includes variants, "testcompany.test"
      assert_includes variants, "test-company.test"
    end
  end

  test "should handle special characters" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test & Company!")
    assert_includes variants, "testcompany.test"
    assert_includes variants, "test-company.test"
    refute_includes variants, "test&company.test"
  end
end
