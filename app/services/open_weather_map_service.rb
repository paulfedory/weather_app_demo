require "json"
require "net/http"

class OpenWeatherMapService
  API_BASE_URL = "https://api.openweathermap.org/data/2.5/weather".freeze
  Response = Struct.new(:success?, :parsed_data)

  def initialize
    @api_key = Rails.application.credentials.openweathermap[:api_key]
  end

  def fetch_weather(zipcode:)
    # fetch data from API
    response = Net::HTTP.get_response(uri(zipcode: zipcode))

    # hide Net::HTTP response object behind a custom Response object
    Response.new(
      success?: response.is_a?(Net::HTTPSuccess),
      parsed_data: response.is_a?(Net::HTTPSuccess) ? JSON.parse(response.body) : nil
    )
  rescue StandardError
    Response.new(success?: false, parsed_data: nil)
  end

  private

  def uri(zipcode:)
    URI("#{API_BASE_URL}?zip=#{zipcode},us&appid=#{@api_key}&units=imperial")
  end
end
