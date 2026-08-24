from scripts.normalize import Normalizer
from scripts.merge import Merger
from scripts.enrich_missing import MissingValueEnricher
from scripts.export import Exporter


def main():

    normalizer = Normalizer()

    data = normalizer.load()

    merger = Merger()

    final = merger.merge(data)

    enricher = MissingValueEnricher()

    final = enricher.enrich(final)

    exporter = Exporter()

    exporter.export(final)

    print("\nPipeline Finished Successfully")


if __name__ == "__main__":
    main()