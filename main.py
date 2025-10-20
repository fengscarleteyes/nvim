import os
import subprocess


def main() -> None:
    # myproxy :str = "http://192.168.10.118:7890"
    myproxy: str = "http://192.168.43.1:7890"
    mylocal: str = "localhost,127.0.0.1"

    os.environ["NO_PROXY"] = mylocal
    os.environ["HTTP_PROXY"] = myproxy
    os.environ["HTTPS_PROXY"] = myproxy
    os.environ["ALL_PROXY"] = myproxy
    # export SOCKET_PROXY=socket5://192.168.43.1:7890
    # export SOCKET5_PROXY=socket5://192.168.43.1:7890
    # subprocess.call("nvim")
    result = subprocess.run(
        "nvim",
        # capture_output=True,
        text=True,
        check=True,
    )
    print(result)


if __name__ == "__main__":
    main()
