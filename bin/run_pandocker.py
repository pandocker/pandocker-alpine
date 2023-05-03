import subprocess as sp
import argparse

DOCKER = "docker run --rm -it -v{pwd}:/workdir k4zuki/pandocker-alpine:{tag}"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("pwd")
    parser.add_argument("tag", default="2.19")
    args = parser.parse_args()
    sp.run(["cd", args.pwd], shell=True)
    sp.run("pwd", shell=True)
    sp.run(DOCKER.format(pwd=args.pwd, tag=args.tag), shell=True)


if __name__ == '__main__':
    main()
