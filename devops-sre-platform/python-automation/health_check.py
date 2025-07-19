import requests
import time
import os

URL = os.getenv("SERVICE_URL", "http://java-backend:8080/actuator/health")

def check_health():
    try:
        response = requests.get(URL, timeout=5)
        if response.status_code == 200:
            print("✅ Service healthy")
        else:
            print(f"❌ Unhealthy: HTTP {response.status_code}")
    except Exception as e:
        print(f"⚠️ Error: {e}")

# 🔁 Infinite loop to keep container alive and run every 60s
if __name__ == "__main__":
    while True:
        check_health()
        time.sleep(60)