#!/usr/bin/env python3

import os
import argparse
import json
import sys

# 定义禁止使用的 MATLAB 关键字/内置函数
FORBIDDEN_DICT = [
    "exist",
    "global",
    # "nargin",
    "nargout",
    "narginchk",
    "nargoutchk",
    "inputname",
    "varargin",
    "varargout",
    # "eval",
    "evalc",
    "feval",
    "evalin",
    "assignin",
    "who",
    "whos",
]


def split_code_comment(line):
    """
    分割代码部分和注释部分，正确处理字符数组中的单引号转义。
    """
    code_part = []
    in_char_array = False
    prev_quote = False  # 用于跟踪前一个字符是否是单引号

    for c in line:
        if in_char_array:
            code_part.append(c)
            if c == "'":
                if prev_quote:
                    # 遇到两个单引号，转义为一个，重置prev_quote
                    prev_quote = False
                else:
                    prev_quote = True
            else:
                if prev_quote:
                    # 前一个字符是单引号且当前字符不是单引号，退出字符数组状态
                    in_char_array = False
                prev_quote = False
        else:
            if c == "%":
                # 注释开始，忽略剩余部分
                break
            elif c == "'":
                # 进入字符数组状态
                in_char_array = True
                code_part.append(c)
                prev_quote = False
            else:
                code_part.append(c)
    return "".join(code_part)


def check_no_string(task):
    """
    检查文件中是否使用了双引号字符串（代码部分）。
    """
    msgs = []
    file_path = task["matlab_file_path"]
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, start=1):
                code_part = split_code_comment(line)
                if '"' in code_part:
                    msgs.append(
                        f"Line {line_num}: String using double quotes detected: {line.strip()}"
                    )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")
    return msgs


def check_empty_line(task):
    """
    检查是否存在连续三个或更多空行。
    """
    msgs = []
    file_path = task["matlab_file_path"]
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            lines = [line.rstrip("\n") for line in f]
            consecutive_empty = 0
            start_line = None
            for idx, line in enumerate(lines, start=1):
                stripped = line.strip()
                if not stripped:
                    if consecutive_empty == 0:
                        start_line = idx
                    consecutive_empty += 1
                else:
                    if consecutive_empty >= 3:
                        end_line = idx - 1
                        msgs.append(
                            f"Lines {start_line}-{end_line}: {consecutive_empty} consecutive empty lines."
                        )
                    consecutive_empty = 0
                    start_line = None
            # 处理文件末尾的连续空行
            if consecutive_empty >= 3:
                end_line = len(lines)
                msgs.append(
                    f"Lines {start_line}-{end_line}: {consecutive_empty} consecutive empty lines."
                )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")
    return msgs


def is_function_or_class(file_path):
    """
    判断文件是否为函数或类文件（代码部分包含function或classdef）。
    """
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line in f:
                code_part = split_code_comment(line)
                stripped = code_part.strip()
                if stripped.startswith("function") or stripped.startswith("classdef"):
                    return True
        return False
    except Exception:
        return False


def check_no_chinese(task):
    """
    检查是否包含非ASCII字符。
    """
    msgs = []
    file_path = task["matlab_file_path"]

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, start=1):
                non_ascii_chars = []
                for idx, c in enumerate(line):
                    if ord(c) > 127:
                        non_ascii_chars.append((idx + 1, c))  # 列号从1开始
                if non_ascii_chars:
                    chars_info = "".join([f"{c}" for _, c in non_ascii_chars])
                    msgs.append(
                        f"Line {line_num}: Non-ASCII characters found: {chars_info}"
                    )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")
    return msgs


def check_forbidden_keywords(task):
    """
    检查文件的代码部分是否使用了禁止的 MATLAB 关键字。
    """
    global FORBIDDEN_DICT

    msgs = []
    file_path = task["matlab_file_path"]

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            for line_num, line in enumerate(f, start=1):
                code_part = split_code_comment(line)
                words = code_part.split()  # 仅按空格拆分，避免误判子字符串
                for keyword in FORBIDDEN_DICT:
                    if keyword in words:
                        msgs.append(
                            f"Line {line_num}: Forbidden keyword '{keyword}' detected: {line.strip()}"
                        )
    except Exception as e:
        msgs.append(f"Error reading file {file_path}: {e}")

    return msgs


def run_check_tasks(tasks):
    results = []
    results = []
    for task in tasks:
        msgs = (
            check_no_string(task)
            + check_empty_line(task)
            + check_no_chinese(task)
            + check_forbidden_keywords(task)  # 添加关键字检查
        )
        results.append({**task, "msgs": msgs, "status": len(msgs) == 0})
    return results
    return results


def generate_check_tasks(root_dir):
    SKIP_DIRS = [".git", "node_modules", ".deploy_git"]
    root_dir_name = os.path.basename(root_dir)
    root_dir_path = os.path.abspath(root_dir)
    tasks = []
    for subdir, dirs, files in os.walk(root_dir, topdown=True):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        matlab_file_list = [f for f in files if f.endswith(".m")]
        for matlab_file_name in matlab_file_list:
            task = {
                "matlab_file_name": matlab_file_name,
                "matlab_file_path": os.path.abspath(
                    os.path.join(subdir, matlab_file_name)
                ),
                "root_dir_name": root_dir_name,
                "root_dir_path": root_dir_path,
                "dir_name": os.path.relpath(subdir, root_dir),
                "dir_path": os.path.abspath(subdir),
            }
            tasks.append(task)
    return tasks


def show_check_results(results):
    pass_cnt = sum(1 for task_result in results if task_result["status"])
    fail_cnt = len(results) - pass_cnt
    if fail_cnt == 0:
        print("matlab_check: pass")
        return 0
    print(f"matlab_check: [y] {pass_cnt} [x] {fail_cnt}\nFailed tasks:")
    show_limit = 100
    show_cnt = 0
    show_flag = True
    for result in results:
        if not result["status"] and show_flag:
            print(f"file: {result['matlab_file_path']} error: {len(result['msgs'])}")
            for msg in result["msgs"]:
                print(msg)
                show_cnt += 1
                if show_cnt >= show_limit:
                    show_flag = False
                    break
    if not show_flag:
        print("\nToo many errors...")
    return fail_cnt


def output_to_logfile(tasks_results):
    try:
        with open("matlab_check.log", "w", encoding="utf-8") as f:
            for task_result in tasks_results:
                if task_result["status"]:
                    continue
                json.dump(task_result, f, ensure_ascii=False, indent=4)
                f.write("\n")
        print("Check results successfully written to matlab_check.log")
    except Exception as e:
        print(f"Error writing to log file: {e}")


def main():
    parser = argparse.ArgumentParser(description="Matlab File Checker")
    parser.add_argument(
        "root_dir", type=str, help="The root directory to search for .m files."
    )
    parser.add_argument(
        "--verbose", action="store_true", help="Enable verbose output to log file."
    )
    args = parser.parse_args()
    tasks = generate_check_tasks(args.root_dir)
    task_results = run_check_tasks(tasks)
    fail_cnt = show_check_results(task_results)
    if args.verbose:
        output_to_logfile(task_results)
    sys.exit(fail_cnt)


if __name__ == "__main__":
    main()
