import shutil
import subprocess
from pathlib import Path
import sys

SRC_DIR = Path(__file__).parent / "src"
BUILD_DIR = Path(__file__).parent / "build"

if __name__ == "__main__":
    # check if build dir exists, delete if it does
    if BUILD_DIR.exists():
        shutil.rmtree(BUILD_DIR)

    # copy src dir to build dir
    shutil.copytree(SRC_DIR, BUILD_DIR)

    # run Yue compiler on build dir
    print(str(BUILD_DIR))
    status = subprocess.run(["yue", str(BUILD_DIR)])

    # delete Yue source files
    for file in BUILD_DIR.rglob("*.yue"):
        if file.is_file():
            file.unlink()

    # forward Yue build returncode
    sys.exit(status.returncode)
