# README

Fetches Weather from the [OpenWeatherMap API](https://openweathermap.org/).

To start, obtain an API key from OpenWeatherMap by signing up. (it's free, but rate-limited)

Make sure you edit the rails credentials to include your [OpenWeatherMap API](https://openweathermap.org/) key.

```
rails credentials:edit
```

Then add your key to the credentials file:

```
open_weather_map:
  api_key: YOUR_KEY_HERE
```

There are 2 important classes here:

The *OpenWeatherMapService* class (and test) and the *WeatherForecastsController* (and test).

The service class handles calling the API and return the results back in a generic response Struct. Calls to the API are cached for 30 minutes, by zip code.

The controller calls the service according to the zip code entered by the user. There are only 2 actions in the controller: new and create.

## Assumptions:
- The user will only be looking up weather forecasts by zip code, in the US.

## Future considerations:
- Decouple the OpenWeatherMapService and controller further, adding an Adapter class between them to allow for many different kinds of weather providers. (perhaps even selected by the user?)
- Create a class that holds the weather data in a nicer way. Currently just uses a Struct created inside the service class.
- More descriptive errors, currently just says "Unable to fetch weather data" if anything goes wrong.
- Extend the fetching of weather conditions to locations outside the US.
