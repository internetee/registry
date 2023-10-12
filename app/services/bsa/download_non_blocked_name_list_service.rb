module Bsa
  class DownloadNonBlockedNameListService
    include ApplicationService
    include Core::TokenHelper

    attr_reader :suborder_id, :filename

    def self.call(suborder_id:, filename: Time.now.strftime("%Y-%m-%d_%H-%M-%S"))
      new(suborder_id: suborder_id, filename: filename).call
    end

    def initialize(suborder_id:, filename:)
      @suborder_id = suborder_id
      @filename = filename
    end

    def call
      http = connect(url: base_url)
      response = http.get(endpoint, headers.merge(token_format(token)))

      File.open("#{filename}.csv", 'wb') do |file|
        file.write(response.body)
      end

      puts '----'
      puts response.inspect
      puts '-------'

      # TODO: finish with response
      # struct_response(response)
    end

    private

    def endpoint
      "/bsa/api/blockrsporder/#{suborder_id}/nonblockednames"
    end
  end
end
