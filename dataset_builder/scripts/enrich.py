import pandas as pd


class Enricher:

    def enrich(self, merged_df, visitor_df, guide):

        # Merge visitor statistics
        final = merged_df.merge(
            visitor_df,
            left_on="Name",
            right_on="place_name",
            how="left"
        )

        # Build lookup from JSON guide
        guide_lookup = {}

        for place in guide:
            destination = str(place.get("destination_name", "")).strip().lower()
            if destination:
                guide_lookup[destination] = place

        # Create new columns
        final["Best Seasons"] = ""
        final["Activities"] = ""
        final["Budget"] = ""
        final["Hidden Gems"] = ""
        final["Nearest Airport"] = ""
        final["Nearest Railway"] = ""
        final["Cuisine"] = ""
        final["Safety Rating"] = ""

        # Fill extra information
        for index, row in final.iterrows():

            key = str(row["Name"]).strip().lower()

            if key not in guide_lookup:
                continue

            info = guide_lookup[key]

            # Best Seasons
            final.at[index, "Best Seasons"] = ", ".join(
                map(str, info.get("best_seasons", []))
            )

            # Activities
            final.at[index, "Activities"] = ", ".join(
                map(str, info.get("activities_available", []))
            )

            # Budget
            budget = (
                info.get("budget_category", {})
                .get("total_daily_range", [])
            )

            if len(budget) >= 2:
                final.at[index, "Budget"] = f"₹{budget[0]} - ₹{budget[1]}"

            # Hidden Gems
            final.at[index, "Hidden Gems"] = ", ".join(
                map(str, info.get("hidden_gems", []))
            )

            # Nearest Airport
            final.at[index, "Nearest Airport"] = str(
                info.get("nearest_airport", {}).get("name", "")
            )

            # Nearest Railway
            final.at[index, "Nearest Railway"] = str(
                info.get("nearest_railway_station", {}).get("name", "")
            )

            # Cuisine
            final.at[index, "Cuisine"] = ", ".join(
                map(str, info.get("local_cuisine_must_try", []))
            )

            # Safety Rating
            final.at[index, "Safety Rating"] = str(
                info.get("safety_rating", "")
            )

        print("Enriched :", len(final))

        return final