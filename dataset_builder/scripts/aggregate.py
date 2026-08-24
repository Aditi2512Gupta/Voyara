import pandas as pd


class Aggregator:

    def aggregate(self, data):

        visitors = data["visitors"]

        grouped = visitors.groupby(

            "place_name",

            as_index=False

        ).agg({

            "user_rating": "mean",

            "crowd_numeric": "mean",

            "weather_suitability_score": "mean",

            "final_recommendation_score": "mean",

            "latitude": "first",

            "longitude": "first",

            "category": "first"

        })

        print("Aggregated :", len(grouped))

        return grouped