from scripts.helpers import normalize_name, firestore_id


class MasterBuilder:

    def __init__(self):

        self.destinations = {}

    def add_place(self, place):

        key = normalize_name(place["name"])

        if key not in self.destinations:

            self.destinations[key] = place

            self.destinations[key]["id"] = firestore_id(

                place["name"],

                place.get("city", ""),

                place.get("state", "")

            )

            return

        existing = self.destinations[key]

        for field, value in place.items():

            if value is None:
                continue

            if str(value).strip() == "":
                continue

            if str(value).lower() == "nan":
                continue

            old = existing.get(field)

            if (
                old is None
                or str(old).strip() == ""
                or str(old).lower() == "nan"
            ):
                existing[field] = value

    def get_all(self):

        return list(self.destinations.values())