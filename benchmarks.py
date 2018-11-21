#!/usr/bin/env python3

import argparse
import json
import re
import subprocess
import sys

class BenchmarkResult:
    def __init__(self, obj):
        if isinstance(obj, list):
            self.group_name = obj[0][0]
            self.test_name = obj[0][1]
            self.avg = obj[0][2]
            self.rel_std_dev = obj[0][3]
        elif isinstance(obj, dict):
            self.group_name = ""
            self.test_name = obj["name"]
            self.avg = obj["avg"]
            self.rel_std_dev = obj["rel_std_dev"]
        else:
            raise ValueError

    def __str__(self):
        return self.test_name + " " + self.avg + " " + self.rel_std_dev + "%"

class BenchmarkGroup:
    def __init__(self, name):
        self.name = name
        self.results = []

    def add_result(self, result):
        self.results.append(result)

class BenchmarkRun:
    def __init__(self, swift_ver):
        self.groups = {}
        self.swift_ver = swift_ver

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

class BenchmarkJSONEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, BenchmarkRun):
            run_out = []
            for group_name, group in o.groups.items():
                results_out = []
                for result in group.results:
                    results_out.append({"name": result.test_name, 
                                        "avg": result.avg, 
                                        "rel_std_dev": result.rel_std_dev})
                group_out = {"group_name": group_name, "results": results_out}
                run_out.append(group_out)
            return {"swift_ver": o.swift_ver, "BitByteDataBenchmarks": run_out}
        return json.JSONEncoder.default(self, o)

class BenchmarkJSONDecoder(json.JSONDecoder):
    def __init__(self, *args, **kwargs):
        json.JSONDecoder.__init__(self, object_hook=self.object_hook, *args, **kwargs)

    def object_hook(self, obj):
        if len(obj.items()) == 3 and "name" in obj and "avg" in obj and "rel_std_dev" in obj:
            return BenchmarkResult(obj)
        elif len(obj.items()) == 2 and "group_name" in obj:
            group = BenchmarkGroup(obj["group_name"])
            for result in obj["results"]:
                group.add_result(result)
            return group
        elif len(obj.items()) == 2 and "BitByteDataBenchmarks" in obj and "swift_ver" in obj:
            run = BenchmarkRun(obj["swift_ver"])
            for group in obj["BitByteDataBenchmarks"]:
                run.groups[group.name] = group
            return run
        return obj

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

    swift_command = []
    if args.toolchain is not None:
        swift_command = ["xcrun", "-toolchain", args.toolchain]
    elif args.use_413:
        swift_command = ["xcrun", "-toolchain", "org.swift.41320180727a"]
    swift_command.append("swift")
    command = swift_command + ["test", "-c", "release", "--filter", args.filter]
    # macOS version of 'swift test' outputs to stderr instead of stdout.
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    swift_ver = subprocess.run(swift_command + ["--version"], capture_output=True, check=True, universal_newlines=True).stdout
    run = BenchmarkRun(swift_ver)

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
        f = open(args.save, "w+")
        json.dump(run, f, indent=4, cls=BenchmarkJSONEncoder)
        f.close()

def action_show(args):
    f = open(args.file, "r")
    o = json.load(f, cls=BenchmarkJSONDecoder)
    print(o)

parser = argparse.ArgumentParser(description="A benchmarking tool for BitByteData")
subparsers = parser.add_subparsers(title="commands", help="a command to perform", required=True, metavar="CMD")

# Parser for 'run' command.
parser_run = subparsers.add_parser("run", help="run benchmarks", description="run benchmarks")
parser_run.add_argument("--filter", action="store", default="BitByteDataBenchmarks",
                        help="filter benchmarks (passed as --filter option to 'swift test')")
parser_run.add_argument("--save", action="store", metavar="FILE", help="save output in a specified file")

toolchain_option_group = parser_run.add_mutually_exclusive_group()
toolchain_option_group.add_argument("--toolchain", action="store", metavar="ID",
                                    help="use swift from the toolchain with specified identifier")
toolchain_option_group.add_argument("--413", action="store_true", dest="use_413",
                                    help=("use swift from toolchain with 'org.swift.41320180727a' identifier (this is a "
                                        "toolchain for Swift 4.1.3 which must already be installed; shortcut for "
                                        "'--toolchain org.swift.41320180727a')"))

parser_run.set_defaults(func=action_run)

# Parser for 'show' command.
parser_show = subparsers.add_parser("show", help="print saved benchmarks results", description="print saved benchmarks results")
parser_show.add_argument("file", action="store", metavar="FILE",
                        help="file with benchmarks results in JSON format")
parser_show.set_defaults(func=action_show)

args = parser.parse_args()
args.func(args)
