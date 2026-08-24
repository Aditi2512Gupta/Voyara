import time
import requests
import pandas as pd


API_KEY = "bd8c379ce33d4e6ca264986f433b4829"

URL = "https://api.geoapify.com/v1/geocode/search"


df = pd.read_json("output/final/voyara_local.json")

missing = df[df["latitude"].isna()]

print(f"Missing coordinates : {len(missing)}")


for index, row in missing.iterrows():

    query = ", ".join([
        str(row["name"]),
        str(row["city"]),
        str(row["state"]),
        "India"
    ])

    try:

        response = requests.get(

            URL,

            params={
                "text": query,
                "limit": 1,
                "apiKey": API_KEY,
            },

            timeout=20,
        )

        data = response.json()

        features = data.get("features", [])

        if features:

            props = features[0]["properties"]

            df.at[index, "latitude"] = props["lat"]
            df.at[index, "longitude"] = props["lon"]

            print("✓", row["name"])

        else:

            print("✗", row["name"])

    except Exception as e:

        print("ERROR :", row["name"], e)

    time.sleep(0.25)


df.to_json(

    "output/final/voyara_local.json",

    orient="records",

    indent=2,

    force_ascii=False,

)

print("\nDONE")