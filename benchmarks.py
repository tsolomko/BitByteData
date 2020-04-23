#!/usr/bin/env python3

import argparse
import datetime
import json
import re
import subprocess
import sys

class BenchmarkResult:
    def __init__(self, group, bench, avg, rsd):
        self.group_name = group
        self.test_name = bench
        self.avg = avg
        self.rel_std_dev = rsd

    @classmethod
    def from_json_dict(cls, dct: dict):
        return cls("", dct["name"], dct["avg"], dct["rel_std_dev"])

    # Standard deviation
    @property
    def sd(self):
        return float(self.avg) * float(self.rel_std_dev) / 100

    # Upper bound of uncertainty interval
    @property
    def ub(self):
        return float(self.avg) + self.sd

    # Lower bound of uncertainty interval
    @property
    def lb(self):
        return float(self.avg) - self.sd

class BenchmarkGroup:
    def __init__(self, name):
        self.name = name
        self.results = []

    def add_result(self, result):
        self.results.append(result)
    
    def result(self, name):
        for result in self.results:
            if result.test_name == name:
                return result
        return None

    def _calc_max_len(self):
        max_len = {"test_name": 0, "avg": 0, "rsd": 0}
        for result in self.results:
            max_len["test_name"] = max(len(result.test_name), max_len["test_name"])
            max_len["avg"] = max(len(result.avg), max_len["avg"])
            max_len["rsd"] = max(len(result.rel_std_dev), max_len["rsd"])
        return max_len

class BenchmarkRun:
    def __init__(self, swift_ver, timestamp=None, description=None):
        self.groups = {}
        self.swift_ver = swift_ver
        self.timestamp = timestamp
        self.description = description

    def __str__(self):
        output = ""
        if self.swift_ver is not None:
            output += "{0}".format(self.swift_ver)
        if self.timestamp is not None:
            output += "Timestamp: {0}\n".format(self.timestamp)
        for group_name, group in self.groups.items():
            output += "\n" + group_name + ":\n"
            max_len = group._calc_max_len()
            for result in group.results:
                output += "{test_name: >{test_name_len}} {avg: ^{avg_len}} {rsd: >{rsd_len}}%".format(
                    test_name=result.test_name, avg=result.avg, rsd=result.rel_std_dev,
                    test_name_len=max_len["test_name"], avg_len=max_len["avg"], rsd_len=max_len["rsd"]) + "\n"
        return output

    def new_result(self, result: BenchmarkResult):
        group = self.groups.get(result.group_name, BenchmarkGroup(result.group_name))
        group.add_result(result)
        self.groups[group.name] = group

    def str_compare(self, base, ignore_missing=False):
        output = ""
        regs = 0
        imps = 0
        oks = 0
        for group_name, group in self.groups.items():
            base_group = base.groups.get(group_name)
            base_max_len = {}
            if base_group is None:
                output += "\n" + group_name + ":\n"
                output += "warning: " + group_name + " not found in base benchmarks\n"
            else:
                output += "\n" + group_name + ": NEW | BASE\n"
                base_max_len = base_group._calc_max_len()
            
            max_len = group._calc_max_len()
            
            for result in group.results:
                output += "{test_name: >{test_name_len}} {avg: ^{avg_len}} {rsd: >{rsd_len}}%".format(
                    test_name=result.test_name, avg=result.avg, rsd=result.rel_std_dev,
                    test_name_len=max_len["test_name"], avg_len=max_len["avg"], rsd_len=max_len["rsd"])

                if base_group is not None:
                    base_result = base_group.result(result.test_name)
                    if base_result is not None:
                        output += " | {avg: ^{avg_len}} {rsd: >{rsd_len}}% | ".format(
                            avg=base_result.avg, rsd=base_result.rel_std_dev,
                            avg_len=base_max_len["avg"], rsd_len=base_max_len["rsd"])

                        ub = result.ub
                        lb = result.lb
                        base_ub = base_result.ub
                        base_lb = base_result.lb
                        if (base_lb < ub < base_ub) or (base_lb < lb < base_ub) or (lb < base_ub < ub) or (lb < base_lb < ub):
                            output += "OK\n"
                            oks += 1
                        elif float(result.avg) > float(base_result.avg):
                            diff = round((lb / base_ub - 1) * 100, 2)
                            output += "REG +" + str(diff) + "%\n"
                            regs += 1
                        else:
                            diff = round((1 - ub / base_lb) * 100, 2)
                            output += "IMP -" + str(diff) + "%\n"
                            imps += 1
                    else:
                        output += " | not found in base\n"
                else:
                    output += "\n"

            if not ignore_missing and base_group is not None:
                missing_results = []
                for result in base_group.results:
                    if group.result(result.test_name) is None:
                        missing_results.append(result.test_name)
                if len(missing_results) > 0:
                    output += "warning: following results were found in base benchmarks but not in new:\n"
                    output += ", ".join(missing_results)
                    output += "\n"
        
        total_results = imps + oks + regs
        output += "\nOut of all compared results:\n"
        output += "    " + str(regs) + "/" + str(total_results) + " regressions\n"
        output += "    " + str(imps) + "/" + str(total_results) + " improvements\n"
        output += "    " + str(oks) + "/" + str(total_results) + " no significant changes"
        return output

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
            d = {"swift_ver": o.swift_ver, "timestamp": o.timestamp}
            if o.description is not None:
                d["description"] = o.description
            d["BitByteDataBenchmarks"] = run_out
            return d
        return json.JSONEncoder.default(self, o)

class BenchmarkJSONDecoder(json.JSONDecoder):
    def __init__(self, *args, **kwargs):
        json.JSONDecoder.__init__(self, object_hook=self.object_hook, *args, **kwargs)

    def object_hook(self, obj):
        if len(obj.items()) == 3 and "name" in obj and "avg" in obj and "rel_std_dev" in obj:
            return BenchmarkResult.from_json_dict(obj)
        elif len(obj.items()) == 2 and "group_name" in obj:
            group = BenchmarkGroup(obj["group_name"])
            for result in obj["results"]:
                group.add_result(result)
            return group
        elif len(obj.items()) >= 2 and "BitByteDataBenchmarks" in obj and "swift_ver" in obj:
            run = BenchmarkRun(obj["swift_ver"], obj.get("timestamp"), obj.get("description"))
            for group in obj["BitByteDataBenchmarks"]:
                run.groups[group.name] = group
            return run
        return obj

def _group_benches(benches: list) -> dict:
    groups = {}
    for bench in benches:
        if bench.startswith("BitByteDataBenchmarks."):
            name_parts = bench[22:].split("/")
            if len(name_parts) > 2:
                print("warning: unknown benchmark naming format, skipping.")
                continue
            group = groups.get(name_parts[0], [])
            group.append(name_parts[1])
            groups[name_parts[0]] = group
        else:
            print("warning: non-benchmark test was returned by --filter, skipping.")
    return groups

def _sprun(command):
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    if result.returncode != 0:
        raise subprocess.CalledProcessError(result.returncode, command, output=result.stdout, stderr=result.stderr)
    return result 

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
    elif args.use_5:
        swift_command = ["xcrun", "-toolchain", "org.swift.50320190830a"]
    swift_command.append("swift")

    if args.clean:
        print("Cleaning...")
        clean_command = ["rm", "-rf", ".build/"]
        _sprun(clean_command)

    print("Building...")
    build_command = swift_command + ["build", "--build-tests", "-c", "release"]
    _sprun(build_command)

    list_command = swift_command + ["test", "-c", "release", "-l", "--filter", args.filter]
    bench_list = _sprun(list_command).stdout.decode().splitlines()
    groups = _group_benches(bench_list)
    if len(groups) == 0:
        print("No benchmarks have been found according to the specified options. Exiting...")
        return
    
    print("Benchmarking...")
    swift_ver = subprocess.run(swift_command + ["--version"], stdout=subprocess.PIPE, check=True,
                               universal_newlines=True).stdout
    run = BenchmarkRun(swift_ver, datetime.datetime.now().strftime("%Y-%m-%d %H:%M"), args.desc)

    bench_command = swift_command + ["test", "-c", "release", "--filter"]
    for group, benches in groups.items():
        for bench in benches:
            # Regex symbols are necessary to filter tests exactly according to our benchmark name.
            # Otherwise swift may run more than one benchmark.
            raw_name = "^BitByteDataBenchmarks.{0}/{1}$".format(group, bench)
            command = bench_command + [raw_name]
            output = _sprun(command).stdout.decode().splitlines()
            for line in output:
                matches = p.findall(line.rstrip())
                if len(matches) == 1 and len(matches[0]) == 4:
                    run.new_result(BenchmarkResult(group, bench, matches[0][2], matches[0][3]))

    if args.compare is not None:
        f_base = open(args.compare, "r")
        base = json.load(f_base, cls=BenchmarkJSONDecoder)
        f_base.close()
        print("BASE: " + args.compare)
        if base.swift_ver is not None:
            print(base.swift_ver, end="")
        if base.timestamp is not None:
            print("Timestamp: {0}".format(base.timestamp))
        print(run.str_compare(base, args.filter != "BitByteDataBenchmarks"))
    else:
        print(run)

    if args.save is not None:
        f = open(args.save, "w+")
        json.dump(run, f, indent=4, cls=BenchmarkJSONEncoder)
        f.close()

def action_show(args):
    f = open(args.file, "r")
    o = json.load(f, cls=BenchmarkJSONDecoder)
    f.close()
    if args.compare is not None:
        f_base = open(args.compare, "r")
        base = json.load(f_base, cls=BenchmarkJSONDecoder)
        f_base.close()
        print("BASE: " + args.compare)
        if base.swift_ver is not None:
            print(base.swift_ver, end="")
        if base.timestamp is not None:
            print("Timestamp: {0}".format(base.timestamp))
        print("\nNEW: " + args.file)
        if o.swift_ver is not None:
            print(o.swift_ver, end="")
        if o.timestamp is not None:
            print("Timestamp: {0}".format(o.timestamp))
        print(o.str_compare(base))
    else:
        print(o)

parser = argparse.ArgumentParser(description="A benchmarking tool for BitByteData")
subparsers = parser.add_subparsers(title="commands", help="a command to perform", metavar="CMD")

# Parser for 'run' command.
parser_run = subparsers.add_parser("run", help="run benchmarks", description="run benchmarks")
parser_run.add_argument("--filter", action="store", default="BitByteDataBenchmarks",
                        help="filter benchmarks (passed as --filter option to 'swift test')")
parser_run.add_argument("--save", action="store", metavar="FILE", help="save output in a file")
parser_run.add_argument("--compare", action="store", metavar="BASE", help="compare results with base benchmarks")
parser_run.add_argument("--desc", action="store", metavar="DESC", help="add a description to the results")
parser_run.add_argument("--no-clean", action="store_false", dest="clean", help="don't perform cleaning stage")

toolchain_option_group = parser_run.add_mutually_exclusive_group()
toolchain_option_group.add_argument("--toolchain", action="store", metavar="ID",
                                    help="use swift from the toolchain with specified identifier")
toolchain_option_group.add_argument("--5", action="store_true", dest="use_5",
                                    help=("use swift from the toolchain with 'org.swift.50320190830a' identifier (this is"
                                        " the release toolchain for Swift 5.0.3; useful when Xcode with version less than "
                                        "10.2.1 is used)"))

parser_run.set_defaults(func=action_run)

# Parser for 'show' command.
parser_show = subparsers.add_parser("show", help="print saved benchmarks results", description="print saved benchmarks results")
parser_show.add_argument("file", action="store", metavar="FILE",
                        help="file with benchmarks results in JSON format")
parser_show.add_argument("--compare", action="store", metavar="BASE", help="compare results with base benchmarks")
parser_show.set_defaults(func=action_show)

args = parser.parse_args()
args.func(args)
