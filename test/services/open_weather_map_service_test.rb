require "test_helper"

class OpenWeatherMapServiceTest < ActiveSupport::TestCase
  setup do
    @service = OpenWeatherMapService.new
    @zipcode = "12345"
  end

  test "returns successful response with parsed data when API call succeeds" do
    body = {
      "coord" => { "lon" => -118.4065, "lat" => 34.0901 },
      "weather" => [ { "id" => 800, "main" => "Clear", "description" => "clear sky", "icon" => "01d" } ],
      "base" => "stations",
      "main" => { "temp" => 65.89, "feels_like" => 64.81, "temp_min" => 60.55, "temp_max" => 72.3, "pressure" => 1014, "humidity" => 56, "sea_level" => 1014, "grnd_level" => 994 },
      "visibility" => 10000,
      "wind" => { "speed" => 11.5, "deg" => 250 },
      "clouds" => { "all" => 0 },
      "dt" => 1739824320,
      "sys" => { "type" => 2, "id" => 2098371, "country" => "US", "sunrise" => 1739802968, "sunset" => 1739842762 },
      "timezone" => -28800,
      "id" => 0,
      "name" => "Beverly Hills",
      "cod" => 200
    }

    success_response = Struct.new(:body) do
      def is_a?(klass)
        klass == Net::HTTPSuccess
      end
    end.new(body.to_json)

    Net::HTTP.stub :get_response, success_response do
      response = @service.fetch_weather(zipcode: @zipcode)

      assert response.success?
      assert_equal(body["main"]["temp"], response.current_temp)
    end
  end

  test "returns failed response with nil data when API call fails" do
    error_response = Struct.new(:body) do
      def is_a?(klass)
        klass == Net::HTTPError
      end
    end.new("")

    Net::HTTP.stub :get_response, error_response do
      response = @service.fetch_weather(zipcode: @zipcode)

      assert_not response.success?
      assert_nil response.name
      assert_nil response.current_temp
      assert_nil response.low_temp
      assert_nil response.high_temp
      assert_nil response.conditions
    end
  end

  test "returns failed response with nil data when exception occurs" do
    Net::HTTP.stub :get_response, ->(*args) { raise StandardError } do
      response = @service.fetch_weather(zipcode: @zipcode)

      assert_not response.success?
      assert_nil response.name
      assert_nil response.current_temp
      assert_nil response.low_temp
      assert_nil response.high_temp
      assert_nil response.conditions
    end
  end
end
