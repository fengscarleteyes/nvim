from pathlib import Path

print(__file__)

test_type_001: str = "asd"


def asdasd() -> bool:
    return True


asdasd()

tt = 1


def ttt() -> bool:
    return False


def test() -> Path:
    return Path(__file__)


def test_4(p: str) -> str | None:
    return p if p else None


test_4("test_4")

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
