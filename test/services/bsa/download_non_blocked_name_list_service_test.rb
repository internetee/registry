# frozen_string_literal: true

require 'test_helper'

RESPONSE_DOWNLOAD = 'some,csv,data'

class Bsa::BlockOrderViewServiceTest < ActiveSupport::TestCase
  setup do
    @filename = 'mock-csv'
    token = generate_test_bsa_token(Time.zone.now + 20.minute)
    stub_succesfull_request(token)
  end

  def teardown
    File.delete("#{@filename}.csv") if File.exist?("#{@filename}.csv")
  end

  def test_for_succesfull_downloaded_non_blocked_name
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/1/nonblockednames')
      .to_return(
        status: 200,
        body: RESPONSE_DOWNLOAD.to_json,
        headers: { 'Content-Type' => 'text/csv',
                   'Content-Disposition' => 'attachment; filename="mock-csv.csv"' }
      )

    result = Bsa::DownloadNonBlockedNameListService.call(suborder_id: 1, filename: @filename)

    assert File.exist?("#{@filename}.csv")
    assert_equal RESPONSE_DOWNLOAD, File.read("#{@filename}.csv").gsub('"', '')
    assert result.result?
    assert_equal "Data was added to #{@filename}.csv file", result.body.message
  end

  def test_for_failed_downloaded_non_blocked_name
    stub_request(:get, 'https://api-ote.bsagateway.co/bsa/api/blockrsporder/1/nonblockednames')
      .to_return(
        status: 404,
        headers: { 'Content-Type' => 'application/json' }
      )

    result = Bsa::DownloadNonBlockedNameListService.call(suborder_id: 1, filename: @filename)

    refute File.exist?("#{@filename}.csv")
    refute result.result?
  end

  private

  def stub_succesfull_request(token)
    stub_request(:post, 'https://api-ote.bsagateway.co/iam/api/authenticate/apiKey')
      .to_return(
        status: 200,
        body: { id_token: token }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end
end
