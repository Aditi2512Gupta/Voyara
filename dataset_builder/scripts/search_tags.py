import pandas as pd


def generate_tags(place):

    tags = set()

    fields = [

        "name",

        "state",

        "city",

        "category",

        "best_time"

    ]

    for field in fields:

        value = place.get(field, "")

        if pd.isna(value):
            continue

        value = str(value).strip()

        if value == "" or value.lower() == "nan":
            continue

        tags.add(value.lower())

    activities = place.get("activities", "")

    if not pd.isna(activities):

        for item in str(activities).split(","):

            item = item.strip().lower()

            if item and item != "nan":

                tags.add(item)

    return sorted(tags)