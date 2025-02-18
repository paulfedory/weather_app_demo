require "test_helper"

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  WeatherResponse = Struct.new(:success?, :name, :current_temp, :low_temp, :high_temp, :conditions, :from_cache?)

  setup do
    @zipcode = "12345"
  end

  test "should get new" do
    get new_weather_forecast_path
    assert_response :success
  end

  test "should handle successful weather fetch" do
    success_response = WeatherResponse.new(true, "Beverly Hills", 50, 40, 60, "Clear", false)

    service_mock = Minitest::Mock.new
    service_mock.expect(:fetch_weather, success_response, zipcode: @zipcode)

    OpenWeatherMapService.stub(:new, service_mock) do
      post weather_forecasts_path, params: { zipcode: @zipcode }

      assert_response :success
      assert_template :new
      assert_equal success_response, assigns(:weather_data)
    end
    service_mock.verify
  end

  test "should handle failed weather fetch" do
    failed_response = WeatherResponse.new(false, nil, nil, nil, nil, nil, false)

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
