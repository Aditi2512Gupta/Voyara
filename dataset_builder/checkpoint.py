import pandas as pd
import os


class Checkpoint:

    def __init__(self, path):
        self.path = path

    def load(self):
        if os.path.exists(self.path):
            return pd.read_csv(self.path)
        return None

    def save(self, df):
        df.to_csv(self.path, index=False)