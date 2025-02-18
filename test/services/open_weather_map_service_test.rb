require "test_helper"

class OpenWeatherMapServiceTest < ActiveSupport::TestCase
  setup do
    @service = OpenWeatherMapService.new
    @zipcode = "12345"
  end

  test "returns successful response with parsed data when API call succeeds" do
    success_response = Struct.new(:body) do
      def is_a?(klass)
        klass == Net::HTTPSuccess
      end
    end.new({ temp: 72.5 }.to_json)

    Net::HTTP.stub :get_response, success_response do
      response = @service.fetch_weather(zipcode: @zipcode)

      assert response.success?
      assert_equal({ "temp" => 72.5 }, response.parsed_data)
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
      assert_nil response.parsed_data
    end
  end

  test "returns failed response with nil data when exception occurs" do
    Net::HTTP.stub :get_response, ->(*args) { raise StandardError } do
      response = @service.fetch_weather(zipcode: @zipcode)

      assert_not response.success?
      assert_nil response.parsed_data
    end
  end
end
