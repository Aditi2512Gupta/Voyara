class Validator:

    def validate(self, dataframe):

        print()

        print("Checking Dataset")

        print("--------------------------")

        print("Rows :", len(dataframe))

        print("Duplicate IDs :", dataframe["id"].duplicated().sum())

        print("Missing Name :", dataframe["name"].isna().sum())

        print("Missing State :", dataframe["state"].isna().sum())

        print("Missing Image :", dataframe["image_url"].isna().sum())

        print("--------------------------")