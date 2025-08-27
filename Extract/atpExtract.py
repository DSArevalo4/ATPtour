import requests

url = "https://ipinfo.io/190.60.194.114/json"
try:
    response = requests.get(url)
    data = response.json()
except: 
    print('oh demonios viejo ')