import os
import re
import argparse


def format_matlab_code(code):
    # 处理逗号 , 保证其后有且仅有一个空格
    code = re.sub(r",\s*(?!$)", ", ", code)

    return code


def format_file(input_file, overwrite=False):
    """
    读取 MATLAB 文件，格式化代码后：
    - 如果 `overwrite=True`，直接覆盖原文件
    - 否则返回格式化后的内容
    """
    with open(input_file, "r", encoding="utf-8") as f:
        code = f.read()

    formatted_code = format_matlab_code(code)

    if overwrite:
        with open(input_file, "w", encoding="utf-8", newline="\n") as f:
            f.write(formatted_code)
        print(f"Formatted and overwritten: {input_file}")
    else:
        return code, formatted_code


def format_directory(input_dir, overwrite=False):
    """
    遍历目录中的所有 MATLAB 文件，格式化并输出差异。
    - 如果 `overwrite=True`，直接覆盖文件
    """
    for root, _, files in os.walk(input_dir):
        for file in files:
            if file.endswith(".m"):
                input_file = os.path.join(root, file)
                if overwrite:
                    format_file(input_file, overwrite=True)
                else:
                    original_code, formatted_code = format_file(
                        input_file, overwrite=False
                    )
                    if original_code != formatted_code:
                        print(f"File: {input_file}")
                        print("Changes:")
                        diff_lines(original_code, formatted_code)


def diff_lines(original_code, formatted_code):
    """
    输出原始代码与格式化后的代码的行对比
    """
    original_lines = original_code.splitlines()
    formatted_lines = formatted_code.splitlines()

    for i, (orig_line, formatted_line) in enumerate(
        zip(original_lines, formatted_lines)
    ):
        if orig_line != formatted_line:
            print(f"Line {i + 1}:")
            print(f"  [old]:{orig_line}")
            print(f"  [new]:{formatted_line}")
    print("-" * 40)


def main():
    parser = argparse.ArgumentParser(description="Format MATLAB Code")
    parser.add_argument("--file", type=str, help="Path to a single MATLAB file")
    parser.add_argument("--dir", type=str, help="Directory to search for MATLAB files")
    parser.add_argument(
        "-f",
        "--force",
        action="store_true",
        help="Overwrite the original file with formatted code",
    )
    args = parser.parse_args()

    if not (args.file or args.dir):
        print("Error: You must specify either --file or --dir")
        return

    if args.file:
        if args.force:
            format_file(args.file, overwrite=True)
        else:
            with open(args.file, "r", encoding="utf-8") as f:
                original_code = f.read()
            formatted_code = format_matlab_code(original_code)
            if original_code != formatted_code:
                print(f"Changes for file: {args.file}")
                diff_lines(original_code, formatted_code)
            else:
                print(f"No changes needed for {args.file}")

    elif args.dir:
        if args.force:
            format_directory(args.dir, overwrite=True)
        else:
            format_directory(args.dir, overwrite=False)


if __name__ == "__main__":
    main()
