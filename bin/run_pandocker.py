import subprocess as sp
import argparse

DOCKER = "cd {}; pwd; docker run --rm -it -v$PWD:/workdir k4zuki/pandocker-alpine:2.10"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    args = parser.parse_args()
    sp.run(DOCKER.format(args.input), shell=True)


if __name__ == '__main__':
    main()
