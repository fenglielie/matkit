#!/usr/bin/env python3

import os
import argparse
import json
import sys


def check_empty_lines(file_path):
    """检查是否存在连续三个或更多空行"""
    msgs = []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            lines = [line.rstrip("\n") for line in f]
            empty_count = 0
            start_line = None
            for idx, line in enumerate(lines, start=1):
                if line.strip() == "":
                    if empty_count == 0:
                        start_line = idx
                    empty_count += 1
                else:
                    if empty_count >= 3:
                        msgs.append(
                            f"Lines {start_line}-{idx-1}: {empty_count} consecutive empty lines."
                        )
                    empty_count = 0

            if empty_count >= 3:
                msgs.append(
                    f"Lines {start_line}-{len(lines)}: {empty_count} consecutive empty lines."
                )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")
    return msgs


def check_code_double_quotes(file_path):
    """检查代码部分是否出现双引号"""
    msgs = []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, start=1):
                code_part = line.split("%")[0]
                if '"' in code_part:
                    msgs.append(
                        f"Line {line_num}: Double quotes in code detected: {line.strip()}"
                    )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")
    return msgs


def check_comment_ascii(file_path):
    """检查注释部分是否含非ASCII字符或双引号"""
    msgs = []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, start=1):
                comment_index = line.find("%")
                if comment_index != -1:
                    comment = line[comment_index + 1 :]
                    non_ascii = [c for c in comment if ord(c) > 127]
                    if non_ascii:
                        chars = "".join(non_ascii)
                        msgs.append(
                            f"Line {line_num}: Non-ASCII characters in comment: {chars}"
                        )
                    if '"' in comment:
                        msgs.append(
                            f"Line {line_num}: Double quotes in comment detected: {comment.strip()}"
                        )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")
    return msgs


def check_file(file_path):
    """执行检查"""
    msgs = []
    msgs += check_empty_lines(file_path)
    msgs += check_code_double_quotes(file_path)
    msgs += check_comment_ascii(file_path)
    return {"file": file_path, "msgs": msgs, "status": len(msgs) == 0}


def collect_m_files(root_dir):
    """收集所有 .m 文件"""
    SKIP_DIRS = [".git", "node_modules", ".deploy_git"]
    tasks = []
    for subdir, dirs, files in os.walk(root_dir, topdown=True):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for f in files:
            if f.endswith(".m"):
                tasks.append(os.path.join(subdir, f))
    return tasks


def show_results(results):
    pass_count = sum(1 for r in results if r["status"])
    fail_count = len(results) - pass_count
    if fail_count == 0:
        print("matlab_check: pass")
        return 0
    print(f"matlab_check: [✓] {pass_count} [✗] {fail_count}\nFailed files:")
    show_limit = 100
    shown = 0
    for result in results:
        if not result["status"]:
            print(f"file: {result['file']} errors: {len(result['msgs'])}")
            for msg in result["msgs"]:
                print(msg)
                shown += 1
                if shown >= show_limit:
                    print("\nToo many errors, truncated...")
                    return fail_count
    return fail_count


def write_log(results):
    try:
        with open("matlab_check.log", "w", encoding="utf-8") as f:
            for result in results:
                if not result["status"]:
                    json.dump(result, f, ensure_ascii=False, indent=2)
                    f.write("\n")
        print("Check results written to matlab_check.log")
    except Exception as e:
        print(f"Error writing log: {e}")


def main():
    parser = argparse.ArgumentParser(description="MATLAB Code Style Checker")
    parser.add_argument(
        "root_dir", type=str, help="Root directory to search for .m files"
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Output detailed log to file"
    )
    args = parser.parse_args()

    files = collect_m_files(args.root_dir)
    results = [check_file(f) for f in files]
    fail_count = show_results(results)
    if args.verbose:
        write_log(results)
    sys.exit(fail_count)


if __name__ == "__main__":
    main()
