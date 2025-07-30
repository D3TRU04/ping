import os
import requests
from flask import Flask, render_template, request, redirect, url_for
from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
BING_API_KEY = os.getenv("BING_API_KEY")
BING_ENDPOINT = "https://api.bing.microsoft.com/v7.0/images/search"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

app = Flask(__name__)
place_queue = []

def fetch_places():
    response = supabase.table("food_drink").select("place_id, name, city, image_url").limit(1000).execute()
    return response.data if response.data else []


def fetch_images(query):
    headers = {"Ocp-Apim-Subscription-Key": BING_API_KEY}
    params = {"q": query, "count": 6, "safeSearch": "Moderate"}
    r = requests.get(BING_ENDPOINT, headers=headers, params=params)
    return [img["contentUrl"] for img in r.json().get("value", [])]

@app.route("/")
def index():
    global place_queue
    if not place_queue:
        place_queue = fetch_places()

    if not place_queue:
        return "✅ No more places needing images!"

    place = place_queue[0]
    query = f"{place['name']} {place['city']}"
    image_urls = fetch_images(query)
    return render_template("select_image.html", place=place, images=image_urls)

@app.route("/select", methods=["POST"])
def select_image():
    global place_queue
    place_id = request.form["place_id"]
    action = request.form.get("action")
    
    if action == "keep":
        # Keep current image, just go to next
        place_queue.pop(0)
        return redirect(url_for("index"))
    
    if action == "skip":
        # Skip without any changes
        place_queue.pop(0)
        return redirect(url_for("index"))

    # Otherwise, an image_url was selected
    selected_url = request.form["image_url"]
    supabase.table("food_drink").update({"image_url": selected_url}).eq("place_id", place_id).execute()
    place_queue.pop(0)
    return redirect(url_for("index"))

