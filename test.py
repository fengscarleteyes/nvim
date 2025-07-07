from pathlib import Path

print(__file__)

# asdasd = 123123


def asdasd() -> bool:
  return True


asdasd()


def test():
  return Path(__file__)


def test_4(p):
  return p if p else None


a: Path = Path(__file__)
print(a.parent)

b: Path = Path(__file__)
print(b.cwd())


def test_2() -> bool:
  return True


def test_3() -> bool:
  return False


if __name__ == "__main__":
  print(test_2())
  print(test_3())
