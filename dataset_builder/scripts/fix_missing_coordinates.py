import re
import requests
import pandas as pd


JSON_PATH = "output/final/voyara_local.json"
API_URL = "https://api.geoapify.com/v1/geocode/search"


# Exact corrections for the problematic records.
LOCATION_FIXES = {
    "Chowpatty Beach": ("Mumbai", "Maharashtra"),
    "Lalbagh Botanical Garden": ("Bangalore", "Karnataka"),
    "Cubbon Park": ("Bangalore", "Karnataka"),
    "Vidhana Soudha": ("Bangalore", "Karnataka"),
    "ISKCON Temple Bangalore": ("Bangalore", "Karnataka"),
    "Qutb Shahi Tombs": ("Hyderabad", "Telangana"),
    "Chowmahalla Palace": ("Hyderabad", "Telangana"),
    "Nehru Zoological Park": ("Hyderabad", "Telangana"),
    "Lumbini Park": ("Hyderabad", "Telangana"),
    "Munnar Tea Gardens": ("Munnar", "Kerala"),
    "Fort Kochi": ("Kochi", "Kerala"),
    "Kaas Plateau": ("Satara", "Maharashtra"),
    "Gorumara National Park": ("Jalpaiguri", "West Bengal"),
    "Cooch Behar Palace": ("Cooch Behar", "West Bengal"),
    "Ayodhya Hills": ("Purulia", "West Bengal"),
    "Jagannath Temple": ("Puri", "Odisha"),
    "Sun Temple": ("Konark", "Odisha"),
    "Lingaraj Temple": ("Bhubaneswar", "Odisha"),
    "Khandadhar Waterfall": ("Rourkela", "Odisha"),
    "Barabati Fort": ("Cuttack", "Odisha"),
    "Badaghagara Waterfall": ("Keonjhar", "Odisha"),
    "Sanaghagara Waterfall": ("Kendujhar", "Odisha"),
    "War Memorial": ("Visakhapatnam", "Andhra Pradesh"),

    # Regional / circuit destinations.
    "Pangong Lake (Pangong Tso)": ("Leh", "Ladakh"),
    "Cherrapunji & Mawsmai Area (Sohra region)": ("Cherrapunji", "Meghalaya"),
    "Kutch Interior Circuit (Bhuj–Mandvi–Villages)": ("Bhuj", "Gujarat"),
    "Agumbe & Western Ghats Rainforest Belt": ("Agumbe", "Karnataka"),
    "Jibhi & Tirthan Valley": ("Jibhi", "Himachal Pradesh"),
    "Chitkul & Baspa Valley": ("Chitkul", "Himachal Pradesh"),
    "Great Rann of Kutch (White Desert)": ("Dhordo", "Gujarat"),
    "Astaranga & Ramachandi Beaches (Odisha Quiet Coast)": ("Puri", "Odisha"),
    "Unakoti & North Tripura Heritage Belt": ("Kailashahar", "Tripura"),
    "Bangaram & Kadmat Islands (Lakshadweep Quiet Beaches)": ("Lakshadweep", "Lakshadweep"),
    "Rishikesh & Haridwar (Himalayan Yoga Route)": ("Rishikesh", "Uttarakhand"),
    "Amarkantak Nature–Spiritual Loop": ("Amarkantak", "Madhya Pradesh"),
    "Haridwar–Rishikesh–Char Dham Spiritual Trail (Meta-Circuit Node)": (
        "Rishikesh",
        "Uttarakhand",
    ),
}


def load_api_key():
    """
    Reads the Geoapify key from the existing Flutter ApiConstants file.
    This avoids putting the secret directly into this Python file.
    """

    path = "../lib/core/constants/api_constants.dart"

    try:
        with open(path, "r", encoding="utf-8") as f:
            text = f.read()

        match = re.search(
            r"geoapifyApiKey\s*=\s*['\"]([^'\"]+)['\"]",
            text,
        )

        if not match:
            raise RuntimeError("Geoapify API key not found.")

        return match.group(1)

    except FileNotFoundError:
        raise RuntimeError(
            "Could not find ../lib/core/constants/api_constants.dart"
        )


def main():

    api_key = load_api_key()

    df = pd.read_json(JSON_PATH)

    missing = df["latitude"].isna()

    print("Missing coordinates:", missing.sum())

    # -------------------------------------------------
    # 1. Fix city/state values
    # -------------------------------------------------

    for index, row in df[missing].iterrows():

        name = str(row["name"]).strip()

        if name in LOCATION_FIXES:

            city, state = LOCATION_FIXES[name]

            df.at[index, "city"] = city
            df.at[index, "state"] = state

    # -------------------------------------------------
    # 2. Geocode
    # -------------------------------------------------

    for index, row in df[df["latitude"].isna()].iterrows():

        name = str(row["name"]).strip()
        city = str(row["city"]).strip()
        state = str(row["state"]).strip()

        query_parts = [name]

        if city:
            query_parts.append(city)

        if state:
            query_parts.append(state)

        query_parts.append("India")

        query = ", ".join(query_parts)

        print(f"\nSearching: {query}")

        try:

            response = requests.get(
                API_URL,
                params={
                    "text": query,
                    "limit": 1,
                    "filter": "countrycode:in",
                    "apiKey": api_key,
                },
                timeout=20,
            )

            if response.status_code != 200:
                print(
                    f"ERROR {response.status_code}: "
                    f"{response.text[:200]}"
                )
                continue

            data = response.json()

            features = data.get("features", [])

            if not features:
                print("NOT FOUND")
                continue

            props = features[0].get("properties", {})

            lat = props.get("lat")
            lon = props.get("lon")

            if lat is None or lon is None:
                print("NO COORDINATES")
                continue

            df.at[index, "latitude"] = lat
            df.at[index, "longitude"] = lon

            print(
                f"FOUND: {lat}, {lon}"
            )

        except Exception as e:

            print("ERROR:", e)

    # -------------------------------------------------
    # 3. Save
    # -------------------------------------------------

    df.to_json(
        JSON_PATH,
        orient="records",
        indent=2,
        force_ascii=False,
    )

    print("\nCoordinates saved.")

    remaining = df["latitude"].isna().sum()

    print("Still missing:", remaining)


if __name__ == "__main__":
    main()