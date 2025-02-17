require "test_helper"

class WeatherForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get weather_forecasts_new_url
    assert_response :success
  end

  test "should get create" do
    get weather_forecasts_create_url
    assert_response :success
  end
end
