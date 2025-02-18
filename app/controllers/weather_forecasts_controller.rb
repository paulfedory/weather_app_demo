class WeatherForecastsController < ApplicationController
  def new
  end

  def create
    weather_response = fetch_weather_data

    if weather_response.success?
      @weather_data = weather_response
      render :new
    else
      flash[:error] = "Unable to fetch weather data"
      redirect_to root_path
    end
  end

  private

  def fetch_weather_data
    OpenWeatherMapService.new.fetch_weather(zipcode: params[:zipcode])
  end
end
