import json
import pandas as pd


class Normalizer:

    def __init__(self):

        self.top_places = None
        self.images = None
        self.visitors = None
        self.guide = None

    def load(self):

        print("Loading datasets...")

        self.top_places = pd.read_csv(
            "sources/Top Indian Places to Visit.csv"
        )

        print(self.top_places.columns.tolist())

        self.images = pd.read_excel(
            "sources/Data set of famous India tourist places along with there images.xlsx"
        )

        self.visitors = pd.read_csv(
            "sources/indian_tourist_places_dataset.csv"
        )

        with open(
            "sources/india_tourism_dataset.json",
            encoding="utf-8"
        ) as f:

            self.guide = json.load(f)

        print("Datasets Loaded Successfully")

        return {
            "top_places": self.top_places,
            "images": self.images,
            "visitors": self.visitors,
            "guide": self.guide
        }