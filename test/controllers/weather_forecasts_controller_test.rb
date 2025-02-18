require "test_helper"

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  WeatherResponse = Struct.new(:success?, :parsed_data)

  setup do
    @zipcode = "12345"
  end

  test "should get new" do
    get new_weather_forecast_path
    assert_response :success
  end

  test "should handle successful weather fetch" do
    success_response = WeatherResponse.new(
      true,
      {
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
    )

    service_mock = Minitest::Mock.new
    service_mock.expect(:fetch_weather, success_response, zipcode: @zipcode)

    OpenWeatherMapService.stub(:new, service_mock) do
      post weather_forecasts_path, params: { zipcode: @zipcode }

      assert_response :success
      assert_template :new
      assert_equal success_response.parsed_data, assigns(:weather_data)
    end
    service_mock.verify
  end

  test "should handle failed weather fetch" do
    failed_response = WeatherResponse.new(false, nil)

    service_mock = Minitest::Mock.new
    service_mock.expect(:fetch_weather, failed_response, zipcode: @zipcode)

    OpenWeatherMapService.stub(:new, service_mock) do
      post weather_forecasts_path, params: { zipcode: @zipcode }

      assert_redirected_to root_path
      assert_equal "Unable to fetch weather data", flash[:error]
    end
    service_mock.verify
  end
end
