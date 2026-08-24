import re


def normalize_name(name):

    if not name:
        return ""

    name = str(name).lower().strip()

    # Common replacements
    name = name.replace("&", "and")

    # Remove text inside brackets
    name = re.sub(r"\(.*?\)", "", name)

    # Remove punctuation
    name = re.sub(r"[^\w\s]", " ", name)

    # Remove common tourism words
    remove_words = [
        "the",
        "fort",
        "temple",
        "palace",
        "beach",
        "lake",
        "river",
        "waterfall",
        "falls",
        "national park",
        "national",
        "park",
        "sanctuary",
        "wildlife",
        "museum",
        "church",
        "mosque",
        "memorial",
        "garden",
        "hill",
        "hills"
    ]

    for word in remove_words:
        name = name.replace(word, " ")

    # Remove multiple spaces
    name = re.sub(r"\s+", " ", name)

    return name.strip()


def firestore_id(name, city="", state=""):

    text = f"{name}_{city}_{state}"

    text = normalize_name(text)

    text = text.replace(" ", "_")

    return text


def safe(value, default=""):

    if value is None:
        return default

    if str(value).lower() == "nan":
        return default

    return value