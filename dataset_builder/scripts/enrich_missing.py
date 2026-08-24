import pandas as pd


class MissingValueEnricher:

    def enrich(self, df):

        print("Filling missing values...")

        defaults = {
            "rating": 4.3,
            "entry_fee": 0,
            "visit_duration": 2,
            "best_time": "Morning",
            "category": "Attraction",
            "city": "",
            "state": "",
            "activities": "",
            "hidden_gems": "",
            "nearest_airport": "",
            "nearest_railway": "",
            "cuisine": "",
            "safety_rating": 8,
        }

        for column, value in defaults.items():

            if column in df.columns:
                df[column] = df[column].fillna(value)

        if "image_url" in df.columns:
            df["image_url"] = df["image_url"].fillna(
                "https://placehold.co/800x600/png?text=Voyara"
            )

        return df