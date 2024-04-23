require 'uri'
require 'net/http'
require 'openssl'

class SupplierApiClient
  BASE_URL = 'https://5f2be0b4ffc88500167b85a0.mockapi.io/suppliers'.freeze

  def self.get_data(endpoint)
    url = URI("#{BASE_URL}/#{endpoint}")
    http_get(url)
  end

  private_class_method def self.http_get(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(url)
    request['Content-Type'] = 'application/json'

    begin
      parse_http_response(trigger_http_request(http, request))
    rescue JSON::ParserError
      { error_body: { code: 500, message: 'Failed to parse response body as JSON', type: 'api_error'} }
    end
  end

  private_class_method def self.trigger_http_request(http, request)
    http.request(request)
  end

  # This methods logs 5xx error (if any) occurred on Supplier's API server and returns 500 to Ascenda's user stating Internal Server Error
  # Otherwise parses and returns response body
  private_class_method def self.parse_http_response(response)
    if server_error?(response)
      Rails.logger.error("<<<<< Server Error occurred on Supplier API : #{response.message} >>>>>")
      return { error_body: { code: 500, message: 'Internal Server Error', type: 'http_network_error' } }
    end

    return { error_body: { code: response.code.to_i, message: response.body, type: 'api_error' } } unless response.code.to_i == 200

    JSON.parse(response.read_body)
  end

  private_class_method def self.server_error?(response)
    status_code = response.code.to_i
    status_code >= 500 && status_code < 600
  end

end
