#!/usr/bin/env python3

import argparse
import re
import subprocess
import sys

class BenchmarkResult:
    def __init__(self, regex_matches):
        self.group_name = regex_matches[0][0]
        self.test_name = regex_matches[0][1]
        self.avg = regex_matches[0][2]
        self.rel_std_dev = regex_matches[0][3]

    def __str__(self):
        return self.test_name + " " + self.avg + " " + self.rel_std_dev + "%"

class BenchmarkGroup:
    def __init__(self, name):
        self.name = name
        self.results = []

    def add_result(self, result):
        self.results.append(result)

class BenchmarkRun:
    def __init__(self):
        self.groups = {}

    def __str__(self):
        output = ""
        for group_name, group in self.groups.items():
            output += "\n" + group_name + ":\n"
            for result in group.results:
                output += "    " + str(result) + "\n"
        return output

    def new_result(self, regex_matches):
        result = BenchmarkResult(regex_matches)
        group = self.groups.get(result.group_name, BenchmarkGroup(result.group_name))
        group.add_result(result)
        self.groups[group.name] = group

def action_run(args):
    # Output format of 'swift test' differs between macOS and Linux platforms.
    regex = ""
    if sys.platform == "darwin":
        regex = (r"Test Case '-\[BitByteDataBenchmarks\.(.+Benchmarks) (test.+)\]'.+average: (\d+.\d+), "
                r"relative standard deviation: (\d+.\d+)\%")
    elif sys.platform == "linux":
        regex = (r"Test Case '(.+Benchmarks)\.(test.+)'.+average: (\d+.\d+), "
                r"relative standard deviation: (\d+.\d+)\%")
    else:
        raise Exception("Unknown platform: " + sys.platform) 
    p = re.compile(regex)

    command = ["swift", "test", "-c", "release", "--filter", args.filter]
    # macOS version of 'swift test' outputs to stderr instead of stdout.
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    run = BenchmarkRun()

    while True:
        line = process.stdout.readline().decode()
        if line == "" and process.poll() is not None:
            break
        sys.stdout.write(line)
        sys.stdout.flush()
        matches = p.findall(line.rstrip())
        if len(matches) == 1 and len(matches[0]) == 4:
            run.new_result(matches)

    exit_code = process.returncode

    if exit_code != 0:
        raise subprocess.CalledProcessError(exit_code, command)
    
    output = str(run)
    print(output)

    if args.save is not None:
        f = open(args.save,"w+")
        f.write(output)
        f.close()

parser = argparse.ArgumentParser(description="A benchmarking tool for BitByteData")
subparsers = parser.add_subparsers(title="commands", help="a command to perform", required=True, metavar="CMD")

# Parser for 'run' command.
parser_run = subparsers.add_parser("run", help="run benchmarks", description="run benchmarks")
parser_run.add_argument("--filter", action="store", default="BitByteDataBenchmarks",
                        help="filter benchmarks (passed as --filter option to 'swift test')")
parser_run.add_argument("--save", action="store", metavar="FILE", help="save output in a specified file")
parser_run.set_defaults(func=action_run)

args = parser.parse_args()
args.func(args)
