import time


class Logger:

    def __init__(self):
        self.start = time.time()

    def progress(self, current, total):

        elapsed = int(time.time() - self.start)

        print(
            f"[{current}/{total}] "
            f"{round(current*100/total,1)}% "
            f"Elapsed: {elapsed}s"
        )