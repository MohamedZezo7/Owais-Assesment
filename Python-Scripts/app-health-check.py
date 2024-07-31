import requests

def check_health(url):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            print("Health check passed.")
        else:
            print("Health check failed.")
    except Exception as e:
        print(f"Health check error: {e}")

if __name__ == "__main__":
    check_health("https://facebooks.com/health")
