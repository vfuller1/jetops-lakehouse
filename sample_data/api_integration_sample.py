import requests

# Nutrition Facts API Example (USDA)
def get_nutrition_info(query):
    api_key = "DEMO_KEY"  # Replace with your own key for real use
    url = f"https://api.nal.usda.gov/fdc/v1/foods/search?query={query}&api_key={api_key}"
    response = requests.get(url)
    if response.status_code == 200:
        data = response.json()
        return data['foods'][0] if data['foods'] else None
    return None

# Random User API Example
def get_random_user():
    url = "https://randomuser.me/api/"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()['results'][0]
    return None

# OpenWeatherMap API Example
def get_weather(city):
    api_key = "DEMO_KEY"  # Replace with your own key for real use
    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}"
    response = requests.get(url)
    if response.status_code == 200:
        return response.json()
    return None

if __name__ == "__main__":
    print("Nutrition Info for 'Herbalife Formula 1':", get_nutrition_info("Herbalife Formula 1"))
    print("Random User:", get_random_user())
    print("Weather in Los Angeles:", get_weather("Los Angeles"))
