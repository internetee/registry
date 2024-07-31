require 'test_helper'

class BusinessRegistry::DomainNameGeneratorServiceTest < ActiveSupport::TestCase
  test "should generate variants for simple name" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company")
    assert_includes variants, "testcompany"
    assert_includes variants, "test-company"
    assert_includes variants, "test_company"
    assert_includes variants, "testcompany#{Time.current.year}"
  end

  test "should remove legal forms" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company AS")
    assert_includes variants, "testcompany"
    refute_includes variants, "testcompanyas"
  end

  test "should generate variants with current year" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test")
    assert_includes variants, "test#{Time.current.year}"
  end

  test "should handle special characters" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test & Company!")
    assert_includes variants, "testcompany"
    refute_includes variants, "test&company"
  end
end