require 'test_helper'

class VersionsTest < ActiveSupport::TestCase

  def test_if_gets_all_versions_without_error_if_ignored_column_present
    @nameserver = nameservers(:shop_ns1)
    @nameserver.update(hostname: 'ns99.bestnames.test')
    @ignored_column_title = Nameserver.ignored_columns.first

    version = NameserverVersion.last
    hash = version.object
    hash[@ignored_column_title] = 123456
    version.update(object: hash)

    assert_nothing_raised do
      Nameserver.all_versions_for([@nameserver.id], Time.zone.now)
    end
  end

  def test_if_gets_all_versions_without_error_if_no_ignored_column
    @account = accounts(:cash)
    @account.update(currency: 'USD')

    assert_nothing_raised do
      Account.all_versions_for([@account.id], Time.zone.now)
    end
  end
end
