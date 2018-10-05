#!/usr/bin/env python3

import sys
import re

benchmarks = dict()

for line in sys.stdin:
    line = line.rstrip()
    print(line)
    p = re.compile("Test Case '-\[BitByteDataBenchmarks\.(.+Benchmarks) (test.+)\]'.+average: (\d+.\d+), relative standard deviation: (\d+.\d+)\%")
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
