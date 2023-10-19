# frozen_string_literal: true

module Bsa
  class DownloadNonBlockedNameListService
    include ApplicationService
    include Core::TokenHelper

    attr_reader :suborder_id, :filename

    def self.call(suborder_id:, filename: Time.zone.now.strftime('%Y-%m-%d_%H-%M-%S'))
      new(suborder_id: suborder_id, filename: filename).call
    end

    def initialize(suborder_id:, filename:)
      @suborder_id = suborder_id
      @filename = filename
    end

    def call
      http = connect(url: base_url)
      response = http.get(endpoint, headers.merge(token_format(token)))

      if [OK, ACCEPTED].include? response.code
        File.open("#{filename}.csv", 'wb') do |file|
          file.write(response.body)
        end

        Struct.new(:result?, :body).new(true, OpenStruct.new(message: "Data was added to #{filename}.csv file"))
      else
        Struct.new(:result?, :error).new(false, OpenStruct.new(message: response.message, code: response.code))
      end
    end

    private

    def endpoint
      "/bsa/api/blockrsporder/#{suborder_id}/nonblockednames"
    end
  end
end
