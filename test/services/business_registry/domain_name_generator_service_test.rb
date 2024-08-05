require 'test_helper'

class BusinessRegistry::DomainNameGeneratorServiceTest < ActiveSupport::TestCase
  test "should generate variants for simple name" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company")
    assert_includes variants, "testcompany"
    assert_includes variants, "test-company"
    assert_includes variants, "test_company"
  end

  test "should generate variants with legal forms" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company OÜ")
    assert_includes variants, "testcompany"
    assert_includes variants, "test-company"
    assert_includes variants, "test_company"
    assert_includes variants, "testcompanyoü"
    assert_includes variants, "testcompanyou"
    assert_includes variants, "testcompany-oü"
    assert_includes variants, "testcompany-ou"
    assert_includes variants, "testcompany_oü"
    assert_includes variants, "testcompany_ou"
    assert_includes variants, "test-companyoü"
    assert_includes variants, "test-companyou"
    assert_includes variants, "test-company-oü"
    assert_includes variants, "test-company-ou"
    assert_includes variants, "test-company_oü"
    assert_includes variants, "test-company_ou"
    assert_includes variants, "test_companyoü"
    assert_includes variants, "test_companyou"
    assert_includes variants, "test_company-oü"
    assert_includes variants, "test_company-ou"
    assert_includes variants, "test_company_oü"
    assert_includes variants, "test_company_ou"
  end

  test "should handle different legal forms" do
    legal_forms = %w[AS OU FIE OÜ MTÜ]
    legal_forms.each do |form|
      variants = BusinessRegistry::DomainNameGeneratorService.generate("Test Company #{form}")
      assert_includes variants, "testcompany#{form.downcase}"
      assert_includes variants, "testcompany-#{form.downcase}"
      assert_includes variants, "testcompany_#{form.downcase}"
      assert_includes variants, "test-company#{form.downcase}"
      assert_includes variants, "test-company-#{form.downcase}"
      assert_includes variants, "test-company_#{form.downcase}"
      assert_includes variants, "test_company#{form.downcase}"
      assert_includes variants, "test_company-#{form.downcase}"
      assert_includes variants, "test_company_#{form.downcase}"
      
      if form.include?('Ü')
        alternative_form = form.tr('Ü', 'U').downcase
        assert_includes variants, "testcompany#{alternative_form}"
        assert_includes variants, "testcompany-#{alternative_form}"
        assert_includes variants, "testcompany_#{alternative_form}"
        assert_includes variants, "test-company#{alternative_form}"
        assert_includes variants, "test-company-#{alternative_form}"
        assert_includes variants, "test-company_#{alternative_form}"
        assert_includes variants, "test_company#{alternative_form}"
        assert_includes variants, "test_company-#{alternative_form}"
        assert_includes variants, "test_company_#{alternative_form}"
      end
    end
  end

  test "should handle special characters" do
    variants = BusinessRegistry::DomainNameGeneratorService.generate("Test & Company!")
    assert_includes variants, "testcompany"
    refute_includes variants, "test&company"
  end
end
