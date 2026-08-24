import pandas as pd

PATH = "output/final/voyara_local.json"

COORDINATES = {
    "Badaghagara Waterfall": (21.60874, 85.55574),
    "Sanaghagara Waterfall": (21.63289, 85.55692),
    "Cherrapunji & Mawsmai Area (Sohra region)": (25.2677, 91.7310),
    "Bangaram & Kadmat Islands (Lakshadweep Quiet Beaches)": (11.08, 72.53),
    "Haridwar–Rishikesh–Char Dham Spiritual Trail (Meta-Circuit Node)": (
        30.10865,
        78.29162,
    ),
}

df = pd.read_json(PATH)

for index, row in df.iterrows():
    name = str(row["name"]).strip()

    if name in COORDINATES:
        lat, lon = COORDINATES[name]
        df.at[index, "latitude"] = lat
        df.at[index, "longitude"] = lon
        print(f"✓ {name}")

df.to_json(
    PATH,
    orient="records",
    indent=2,
    force_ascii=False,
)

print("\nCoordinates updated.")
print("Remaining missing:", df["latitude"].isna().sum())