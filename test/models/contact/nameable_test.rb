require 'test_helper'

class ContactNameableTest < ActiveSupport::TestCase
  setup do
    @contact = contacts(:john)
    @contact.ident_type = Contact::PRIV
  end

  # --- Generic terms (all PRIV contacts, any country) ---

  def test_rejects_generic_org_term_at_end_of_name
    @contact.name = 'Acme Ltd'
    assert @contact.invalid?
    assert_includes @contact.errors[:name], "Private person's name contains organisation term 'Ltd'"
  end

  def test_rejects_generic_org_term_at_beginning_of_name
    @contact.name = 'LLC John'
    assert has_org_term_error?
  end

  def test_rejects_generic_org_term_in_middle_of_name
    @contact.name = 'John Corp Smith'
    assert has_org_term_error?
  end

  def test_rejects_generic_org_term_case_insensitive
    @contact.name = 'Acme ltd'
    assert has_org_term_error?

    @contact.name = 'Acme LTD'
    assert has_org_term_error?
  end

  def test_rejects_all_generic_org_terms
    %w[Ltd PLC LLC Corp Inc Co Limited Corporation Incorporated].each do |term|
      @contact.name = "Test #{term} Name"
      assert has_org_term_error?, "Expected '#{term}' to be rejected"
    end
  end

  def test_rejects_multiword_generic_terms
    ['Public Limited Company', 'Limited Liability Company'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected '#{term}' to be rejected"
    end
  end

  # --- Does not match partial words ---

  def test_does_not_reject_term_inside_another_word
    @contact.name = 'Cody Johnson'
    assert_not has_org_term_error?

    @contact.name = 'Corvette'
    assert_not has_org_term_error?

    @contact.name = 'Reincorporated'
    assert_not has_org_term_error?
  end

  def test_rejects_term_that_looks_like_part_of_word_but_is_standalone
    @contact.name = 'Incorporated Names'
    assert has_org_term_error?
  end

  # --- ORG contacts are not affected ---

  def test_allows_org_terms_for_org_type_contacts
    @contact.ident_type = Contact::ORG
    @contact.ident = '12345678'
    @contact.name = 'Acme Ltd'
    assert_not has_org_term_error?
  end

  # --- Valid PRIV names ---

  def test_allows_regular_priv_name
    @contact.name = 'John Smith'
    assert @contact.valid?, proc { @contact.errors.full_messages }
  end

  # --- EE country-specific terms ---

  def test_rejects_ee_terms_for_ee_priv_contact
    @contact.ident_country_code = 'EE'

    ['OÜ', 'AS', 'SA', 'MTÜ', 'TÜ', 'UÜ',
     'osaühing', 'aktsiaselt', 'sihtasutus',
     'mittetulundusühing', 'täisühing', 'usaldusühing'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected EE term '#{term}' to be rejected"
    end
  end

  def test_does_not_reject_ee_terms_for_other_country
    @contact.ident_country_code = 'US'
    @contact.name = 'Test OÜ'
    assert_not has_org_term_error?
  end

  # --- DE country-specific terms ---

  def test_rejects_de_terms_for_de_priv_contact
    @contact.ident_country_code = 'DE'

    ['GmbH', 'AG', 'Gesellschaft mit beschränkter Haftung', 'Aktiengesellschaft'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected DE term '#{term}' to be rejected"
    end
  end

  def test_does_not_reject_de_terms_for_other_country
    @contact.ident_country_code = 'US'
    @contact.name = 'Test GmbH'
    assert_not has_org_term_error?
  end

  # --- FI country-specific terms ---

  def test_rejects_fi_terms_for_fi_priv_contact
    @contact.ident_country_code = 'FI'

    ['Oy', 'Oyj', 'Osakeyhtiö', 'Julkinen osakeyhtiö'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected FI term '#{term}' to be rejected"
    end
  end

  # --- SE country-specific terms ---

  def test_rejects_se_terms_for_se_priv_contact
    @contact.ident_country_code = 'SE'

    ['AB', 'Aktiebolag'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected SE term '#{term}' to be rejected"
    end
  end

  # --- LV country-specific terms ---

  def test_rejects_lv_terms_for_lv_priv_contact
    @contact.ident_country_code = 'LV'

    ['SIA', 'AS', 'Sabiedrība ar ierobežotu atbildību', 'Akciju sabiedrība'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected LV term '#{term}' to be rejected"
    end
  end

  # --- LT country-specific terms ---

  def test_rejects_lt_terms_for_lt_priv_contact
    @contact.ident_country_code = 'LT'

    ['UAB', 'AB', 'Uždaroji akcinė bendrovė', 'Akcinė bendrovė'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected LT term '#{term}' to be rejected"
    end
  end

  # --- FR country-specific terms ---

  def test_rejects_fr_terms_for_fr_priv_contact
    @contact.ident_country_code = 'FR'

    ['SARL', 'SAS', 'S.A.', 'Société à responsabilité limitée',
     'Société par actions simplifiée', 'Société Anonyme'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected FR term '#{term}' to be rejected"
    end
  end

  # --- IT country-specific terms ---

  def test_rejects_it_terms_for_it_priv_contact
    @contact.ident_country_code = 'IT'

    ['S.r.l.', 'S.p.A.', 'Società a responsabilità limitata', 'Società per Azioni'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected IT term '#{term}' to be rejected"
    end
  end

  # --- NL country-specific terms ---

  def test_rejects_nl_terms_for_nl_priv_contact
    @contact.ident_country_code = 'NL'

    ['B.V.', 'N.V.', 'Besloten Vennootschap', 'Naamloze Vennootschap'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected NL term '#{term}' to be rejected"
    end
  end

  # --- PL country-specific terms ---

  def test_rejects_pl_terms_for_pl_priv_contact
    @contact.ident_country_code = 'PL'

    ['Sp. z o.o.', 'S.A.', 'Spółka z ograniczoną odpowiedzialnością', 'Spółka Akcyjna'].each do |term|
      @contact.name = "Test #{term}"
      assert has_org_term_error?, "Expected PL term '#{term}' to be rejected"
    end
  end

  # --- Country-specific terms not applied cross-country ---

  def test_does_not_reject_fi_terms_for_ee_contact
    @contact.ident_country_code = 'EE'
    @contact.name = 'Test Oy'
    assert_not has_org_term_error?
  end

  def test_does_not_reject_lt_terms_for_de_contact
    @contact.ident_country_code = 'DE'
    @contact.name = 'Test UAB'
    assert_not has_org_term_error?
  end

  # --- Term position edge cases ---

  def test_rejects_term_as_entire_name
    @contact.name = 'Ltd'
    assert has_org_term_error?
  end

  def test_rejects_term_separated_by_comma
    @contact.name = 'Acme,Ltd'
    assert has_org_term_error?
  end

  def test_rejects_term_separated_by_dot
    @contact.name = 'Acme.Ltd'
    assert has_org_term_error?
  end

  def test_rejects_ee_term_case_insensitive
    @contact.ident_country_code = 'EE'

    @contact.name = 'Test oü'
    assert has_org_term_error?

    @contact.name = 'Test OSAÜHING'
    assert has_org_term_error?
  end

  private

  def has_org_term_error?
    @contact.validate
    @contact.errors.of_kind?(:name, :org_term_in_priv_name)
  end
end
