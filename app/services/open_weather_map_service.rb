require "json"
require "net/http"

class OpenWeatherMapService
  API_BASE_URL = "https://api.openweathermap.org/data/2.5/weather".freeze
  Response = Struct.new(:success?, :name, :current_temp, :low_temp, :high_temp, :conditions)

  def initialize
    # fetch OpenWeatherMap API key from Rails credentials
    @api_key = Rails.application.credentials.openweathermap[:api_key]
  end

  def fetch_weather(zipcode:)
    # fetch data from API
    response = Net::HTTP.get_response(uri(zipcode: zipcode))

    # hide Net::HTTP response object behind a custom Response object
    # so our usage of Net::HTTP is encapsulated
    if response.is_a?(Net::HTTPSuccess)
      parsed_response = JSON.parse(response.body)

      Response.new(
        success?: true,
        name: parsed_response.dig("name"),
        current_temp: parsed_response.dig("main", "temp"),
        low_temp: parsed_response.dig("main", "temp_min"),
        high_temp: parsed_response.dig("main", "temp_max"),
        conditions: parsed_response.dig("weather", 0, "main")
      )
    else
      error_response
    end
  rescue StandardError
    # if JSON parsing or Net::HTTP request throw an exception, catch the error
    # and return an unsuccessful response object instead
    error_response
  end

  private

  def uri(zipcode:)
    # build URI object with query parameters
    URI("#{API_BASE_URL}?zip=#{zipcode},us&appid=#{@api_key}&units=imperial")
  end

  def error_response
    Response.new(
      success?: false,
      name: nil,
      current_temp: nil,
      low_temp: nil,
      high_temp: nil,
      conditions: nil
    )
  end
end
