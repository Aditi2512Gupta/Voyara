import os

class Exporter:

    def export(self, df):

        os.makedirs("output/master", exist_ok=True)
        os.makedirs("output/final", exist_ok=True)

        # CSV
        df.to_csv(
            "output/master/master_destinations.csv",
            index=False,
            encoding="utf-8"
        )

        # Firestore JSON
        df.to_json(
            "output/final/voyara_firestore.json",
            orient="records",
            indent=4,
            force_ascii=False
        )

        # Local JSON (Flutter assets)
        df.to_json(
            "output/final/voyara_local.json",
            orient="records",
            indent=2,
            force_ascii=False
        )

        print("\nCSV Saved")
        print("Firestore JSON Saved")
        print("Local JSON Saved")