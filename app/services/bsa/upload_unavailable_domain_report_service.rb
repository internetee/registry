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
      uri = URI("#{base_url}")

      checksum = calculate_checksum(@file_path)

      request = Net::HTTP::Post.new(uri)
      request['Authorization'] = "Bearer #{token}"
      request['Content-Type'] = 'multipart/form-data'

      form_data = [
        ['Zone', { "checkSum" => checksum }.to_json ],
        ['File', File.open(@file_path)]
      ]

      request.set_form form_data, 'multipart/form-data'

      response = http.request(request)

      struct_response(response)
    end

    private

    def endpoint
      "/bsa/api/zonefile"
    end

    def form_data_headers
      {
        'Content-Type' => 'multipart/form-data',
      }
    end

    def calculate_checksum(file_path)
      digest = OpenSSL::Digest::SHA256.new
      File.open(file_path, 'rb') do |f|
        while chunk = f.read(4096)
          digest.update(chunk)
        end
      end
      digest.hexdigest
    end
  end
end
