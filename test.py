from pathlib import Path

print(__file__)


def test():
    return Path(__file__)


a: Path = Path(__file__)
print(a.parent)

b: Path = Path(__file__)
