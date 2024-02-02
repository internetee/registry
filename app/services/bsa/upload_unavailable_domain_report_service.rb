module Bsa
  class UploadUnavailableDomainReportService
    include ApplicationService
    include Core::TokenHelper

    attr_reader :file_path

    def self.call(file_path:)
      new(file_path: file_path).call
    end

    def initialize(file_path:)
      @file_path = file_path
    end

    def call
      http = connect(url: base_url)
      uri = URI(base_url.to_s)

      request = configure_request(uri: uri)
      response = http.request(request)

      struct_response(response)
    end

    private

    def configure_request(uri:)
      checksum = calculate_checksum(@file_path)

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{token}"
      request['Content-Type'] = 'multipart/form-data'

      form_data = [
        ['Zone', { 'checkSum' => checksum }.to_json],
        ['File', File.open(@file_path)],
      ]

      request.set_form form_data, 'multipart/form-data'
    end

    def endpoint
      '/bsa/api/zonefile'
    end

    def form_data_headers
      {
        'Content-Type' => 'multipart/form-data',
      }
    end

    def calculate_checksum(file_path)
      digest = OpenSSL::Digest.new('SHA256')
      File.open(file_path, 'rb') do |f|
        digest.update(chunk) while chunk == f.read(4096)
      end
      digest.hexdigest
    end
  end
end
