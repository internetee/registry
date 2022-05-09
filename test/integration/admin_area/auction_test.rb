require 'test_helper'
require 'application_system_test_case'

class AdminAreaAuctionIntegrationTest < ApplicationSystemTestCase
  setup do
    sign_in users(:admin)
    @original_default_language = Setting.default_language
  end

  def test_should_open_index_page
    visit admin_root_path
    click_link_or_button 'Settings', match: :first
    find(:xpath, "//ul/li/a[text()='Auctions']").click

    assert_text 'Auctions'
  end

  def test_search_domains
    visit admin_auctions_path

    auction = auctions(:one)
    fill_in 'domain_matches', :with => auction.domain
    find(:xpath, ".//button[./span[contains(@class, 'glyphicon-search')]]", match: :first).click

    assert_text auction.domain
    assert_text 'auto'
    assert_text 'no_bids'
  end

  def test_filter_no_bids_auction
    auction_one = auctions(:one)
    auction_two = auctions(:idn)

    visit admin_auctions_path
    select "no_bids", :from => "statuses_contains"
    find(:xpath, ".//button[./span[contains(@class, 'glyphicon-search')]]", match: :first).click

    assert_text auction_one.domain
    assert_text auction_two.domain
  end

  def test_manually_create_auction
    visit admin_auctions_path

    fill_in 'domain', :with => 'new-awesome-auction.test'
    find(:id, "new-auction-btn", match: :first).click

    assert_text 'new-awesome-auction.test'
    assert_text 'manual'
    assert_text 'started'
  end

  def test_manually_create_auction_with_punycode
    visit admin_auctions_path

    fill_in 'domain', :with => 'xn--phimtte-10ad.test'
    find(:id, "new-auction-btn", match: :first).click

    assert_text 'xn--phimtte-10ad.test'
    assert_text 'manual'
    assert_text 'started'
  end

  def test_raise_error_if_try_to_add_auction_with_invalid_zone
    visit admin_auctions_path

    fill_in 'domain', :with => 'new-awesome-auction.chuchacha'
    find(:id, "new-auction-btn", match: :first).click

    assert_no_text 'new-awesome-auction.chuchacha'
    assert_text 'Cannot generate domain. Reason: invalid format'
  end

  def test_raise_error_if_try_to_add_auction_with_invalid_format
    visit admin_auctions_path

    fill_in 'domain', :with => '#de$er.test'
    find(:id, "new-auction-btn", match: :first).click

    assert_no_text '#de$er.test'
    assert_text 'Cannot generate domain. Reason: invalid format'
  end

  def test_raise_error_if_try_to_add_same_domain
    visit admin_auctions_path

    fill_in 'domain', :with => 'new-awesome-auction.test'
    find(:id, "new-auction-btn", match: :first).click
    fill_in 'domain', :with => 'new-awesome-auction.test'
    find(:id, "new-auction-btn", match: :first).click

    assert_text 'Adding new-awesome-auction.test failed - domain registered or regsitration is blocked'
  end

  def test_raise_error_if_try_to_add_registred_domain
    visit admin_auctions_path
    domain = domains(:shop)

    fill_in 'domain', :with => domain.name
    find(:id, "new-auction-btn", match: :first).click

    assert_text "Adding #{domain.name} failed - domain registered or regsitration is blocked"
  end

  def test_raise_error_if_try_to_add_blocked_domain
    visit admin_auctions_path
    domain = blocked_domains(:one)

    fill_in 'domain', :with => domain.name
    find(:id, "new-auction-btn", match: :first).click

    assert_text "Adding #{domain.name} failed - domain registered or regsitration is blocked"
  end

  def test_raise_error_if_try_to_add_disputed_domain
    visit admin_auctions_path
    domain = disputes(:active)

    fill_in 'domain', :with => domain.domain_name
    find(:id, "new-auction-btn", match: :first).click

    assert_text "Adding #{domain.domain_name} failed - domain registered or regsitration is blocked"
  end

  def test_upload_invalid_csv_file
    visit admin_auctions_path

    attach_file(:q_file, Rails.root.join('test', 'fixtures', 'files', 'mass_actions', 'invalid_mass_force_delete_list.csv').to_s)
    click_link_or_button 'Upload csv'
    assert_text "Invalid CSV format. Should be column with 'name' where is the list of name of domains!"
  end

  def test_upload_valid_csv_file
    visit admin_auctions_path

    attach_file(:q_file, Rails.root.join('test', 'fixtures', 'files', 'auction_domains_list.csv').to_s)
    click_link_or_button 'Upload csv'
    assert_text "tere.test"
    assert_text "chao.test"
  end

  def test_upload_valid_csv_file_with_invalid_item
    visit admin_auctions_path

    attach_file(:q_file, Rails.root.join('test', 'fixtures', 'files', 'auction_domains_list_with_invalid_item.csv').to_s)
    click_link_or_button 'Upload csv'
    assert_text "tere.test"
    assert_text "chao.test"
    assert_text "These domains were ignored: cha.chacha"
  end

  def test_should_remove_domain_from_reserved_if_it_added_to_auction
    visit admin_auctions_path
    domain = reserved_domains(:one)

    fill_in 'domain', :with => domain.name
    find(:id, "new-auction-btn", match: :first).click

    assert_text domain.name
    assert_text 'manual'
    assert_text 'started'

    visit admin_reserved_domains_path
    assert_no_text domain.name
  end

  def test_should_open_reserved_page_in_modal_window
    visit admin_auctions_path

    find(:id, "reserved-modal", match: :first).click
    assert_text 'Reserved domains'
  end
end
