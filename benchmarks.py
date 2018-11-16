#!/usr/bin/env python3

import argparse
import re
import subprocess
import sys

def action_run(args):
    benchmarks = dict()
        
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

    args = ["swift", "test", "-c", "release", "--filter", "BitByteDataBenchmarks"]
    # macOS version of 'swift test' outputs to stderr instead of stdout.
    process = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    while True:
        line = process.stdout.readline().decode()
        if line == "" and process.poll() is not None:
            break
        sys.stdout.write(line)
        sys.stdout.flush()
        line = line.rstrip()
        matches = p.findall(line)
        if len(matches) == 1 and len(matches[0]) == 4:
            benchmark_name = matches[0][0]
            test_name = matches[0][1]
            avg = matches[0][2]
            rel_std_dev = matches[0][3]
            benchmark = benchmarks.get(benchmark_name, list())
            benchmark.append(test_name + " " + avg + " " + rel_std_dev + "%")
            benchmarks[benchmark_name] = benchmark

    exit_code = process.returncode

    if exit_code != 0:
        raise subprocess.CalledProcessError(exit_code, args)
    
    for benchmark_name, results in benchmarks.items():
        print(benchmark_name + ":")
        for result in results:
            print("    " + result)
        print()

parser = argparse.ArgumentParser(description="A benchmarking tool for BitByteData")
subparsers = parser.add_subparsers(title="commands", help="a command to perform", required=True, metavar="CMD")

# Parser for 'run' command.
parser_run = subparsers.add_parser("run", help="run all benchmarks", description="run all benchmarks")
parser_run.set_defaults(func=action_run)

args = parser.parse_args()
args.func(args)
