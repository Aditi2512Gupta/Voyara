from dataclasses import dataclass

@dataclass
class Destination:

    title: str

    city: str

    district: str

    state: str

    country: str

    latitude: float

    longitude: float

    category: str

    description: str

    wikipedia: str

    heroImage: str

    gallery: list

    tags: list