require "json"
require "net/http"

class WeatherForecastsController < ApplicationController
  def new
  end

  def create
    zip = params[:zipcode]
    api_key = Rails.application.credentials.openweathermap[:api_key]

    uri = URI("https://api.openweathermap.org/data/2.5/weather?zip=#{zip},us&appid=#{api_key}&units=imperial")
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      @weather_data = JSON.parse(response.body)
      render :new
    else
      flash[:error] = "Unable to fetch weather data"
      redirect_to root_path
    end
  end
end
