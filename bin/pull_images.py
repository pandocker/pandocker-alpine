import subprocess as sp
import argparse

DOCKER = "docker pull k4zuki/pandocker-alpine:{tag}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("tag", default="2.19")
    args = parser.parse_args()
    sp.run(DOCKER.format(tag=args.tag), shell=True)


if __name__ == '__main__':
    main()
