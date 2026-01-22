#!/bin/bash

# OpenWeatherMap configuration
API_KEY="dc528d0611095162a530d4d5b1470fcd" # Replace with your API key from openweathermap.org
CITY="Rourkela"                            # Replace with your city name
UNITS="metric"                             # Use "imperial" for Fahrenheit

# Fetch weather data
response=$(curl -sf "http://api.openweathermap.org/data/2.5/weather?q=${CITY}&appid=${API_KEY}&units=${UNITS}")

if [ -z "$response" ]; then
    echo "Error fetching weather"
    exit 1
fi

# Parse JSON response
temp=$(echo "$response" | jq -r '.main.temp' | xargs printf "%.0f")
condition=$(echo "$response" | jq -r '.weather[0].main')

# Output format: "Temperature°C - Condition"
if [ "$UNITS" = "metric" ]; then
    echo "${temp}°C - ${condition}"
else
    echo "${temp}°F - ${condition}"
fi
