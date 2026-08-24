import pandas as pd

from scripts.master_builder import MasterBuilder
from scripts.search_tags import generate_tags


class Merger:

    def merge(self, data):

        print("Building Master Database...")

        builder = MasterBuilder()

        # -------------------------
        # DATASET 1
        # -------------------------

        top = data["top_places"]

        for _, row in top.iterrows():

            builder.add_place({

                "name": row.get("Name", ""),
                "state": row.get("State", ""),
                "city": row.get("City", ""),
                "category": row.get("Type", ""),
                "rating": row.get("Google reviewrating", row.get("Google review rating", None)),
                "entry_fee": row.get("Entrance Fee in INR", None),
                "visit_duration": row.get("time needed to visit in hrs", None),
                "best_time": row.get("Best Time to visit", "")

            })

        # -------------------------
        # DATASET 2
        # -------------------------

        images = data["images"]

        for _, row in images.iterrows():

            image = row.get("Image URL", "")

            if str(image).lower() != "nan":

                builder.add_place({

                    "name": row["Name"],

                    "image_url": image

                })

        # -------------------------
        # DATASET 3
        # -------------------------

        grouped = data["visitors"].groupby(

            "place_name",

            as_index=False

        ).agg({

            "latitude": "first",
            "longitude": "first",
            "category": "first",
            "user_rating": "mean"

        })

        for _, row in grouped.iterrows():

            builder.add_place({

                "name": row["place_name"],
                "category": row["category"],
                "latitude": row["latitude"],
                "longitude": row["longitude"],
                "rating": row["user_rating"]

            })

        # -------------------------
        # DATASET 4
        # -------------------------

        for place in data["guide"]:

            builder.add_place({

                "name": place["destination_name"],

                "activities": ", ".join(
                    place.get("activities_available", [])
                ),

                "hidden_gems": ", ".join(
                    place.get("hidden_gems", [])
                ),

                "nearest_airport": place["nearest_airport"]["name"],

                "nearest_railway": place["nearest_railway_station"]["name"],

                "cuisine": ", ".join(
                    place.get("local_cuisine_must_try", [])
                ),

                "safety_rating": place.get("safety_rating", "")

            })

        master = pd.DataFrame(builder.get_all())

        master["search_tags"] = master.apply(

            generate_tags,

            axis=1

        )

        print()

        print("Master Destinations :", len(master))

        return master