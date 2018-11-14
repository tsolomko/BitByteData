#!/usr/bin/env python3

import argparse
import re
import sys

def action_run(args):
    benchmarks = dict()

    for line in sys.stdin:
        line = line.rstrip()
        print(line)
        p = None
        # Output format of 'swift test' differs between macOS and Linux platforms.
        if sys.platform == "darwin":
            p = re.compile(r"Test Case '-\[BitByteDataBenchmarks\.(.+Benchmarks) (test.+)\]'.+average: (\d+.\d+), "
                            r"relative standard deviation: (\d+.\d+)\%")
        elif sys.platform == "linux":
            p = re.compile(r"Test Case '(.+Benchmarks)\.(test.+)'.+average: (\d+.\d+), "
                            r"relative standard deviation: (\d+.\d+)\%")
        else:
            raise Exception("Unknown platform: " + sys.platform) 
        
        matches = p.findall(line)
        if len(matches) == 1 and len(matches[0]) == 4:
            benchmark_name = matches[0][0]
            test_name = matches[0][1]
            avg = matches[0][2]
            rel_std_dev = matches[0][3]
            benchmark = benchmarks.get(benchmark_name, list())
            benchmark.append(test_name + " " + avg + " " + rel_std_dev + "%")
            benchmarks[benchmark_name] = benchmark

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
