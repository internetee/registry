require 'test_helper'

class DomainVersionTest < ActiveSupport::TestCase
  def setup
    super

    @domain = domains(:shop)
    @contacts = @domain.contacts
    @user = users(:registrant)
  end

  def teardown
    super
  end

  def test_assigns_creator_to_paper_trail_whodunnit
    duplicate_domain = prepare_duplicate_domain

    PaperTrail.whodunnit = @user.id_role_username
    assert_difference 'duplicate_domain.versions.count', 2 do
      duplicate_domain.save!
    end

    assert_equal(duplicate_domain.creator, @user)
    assert_equal(duplicate_domain.updator, @user)
    assert_equal(duplicate_domain.creator_str, @user.id_role_username)
    assert_equal(duplicate_domain.updator_str, @user.id_role_username)
  end

  def test_assigns_updator_to_paper_trail_whodunnit
    PaperTrail.whodunnit = @user.id_role_username

    assert_difference '@domain.versions.count', 2 do
      @domain.apply_registry_lock
    end

    assert_equal(@domain.updator, @user)
    assert_equal(@domain.updator_str, @user.id_role_username)
  end

  private

  def prepare_duplicate_domain
    duplicate_domain = @domain.dup
    duplicate_domain.tech_contacts << @contacts
    duplicate_domain.admin_contacts << @contacts
    duplicate_domain.name = 'duplicate.test'
    duplicate_domain.uuid = nil

    duplicate_domain
  end
end
