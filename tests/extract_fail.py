# Copyright (c) 2026 Hygon Information Technology Co., Ltd.
# SPDX-License-Identifier: Apache-2.0

# DeepSpeed Team

import re
import pandas as pd
import sys


def clean_ansi(text):
    """移除 ANSI 转义序列（如 \x1b[31m）"""
    ansi_escape = re.compile(r'\x1B\[[0-?]*[ -/]*[@-~]')
    return ansi_escape.sub('', text)


def extract_test_error_or_failure(line):
    """
    兼容两种格式：
      - ERROR path/to/test.py - Exception: message
      - ERROR path/to/test.py
      - FAILED ... 同理
    """
    clean_line = clean_ansi(line).strip()

    # Split on the final separator. Parameter IDs can themselves contain
    # hyphens, e.g. ``test[qbit8-bws2] - AttributeError``.
    match_status = re.match(r'^(ERROR|FAILED)\s+(.+)$', clean_line)
    if match_status and " - " in match_status.group(2):
        test, reason = match_status.group(2).rsplit(" - ", 1)
        return {"type": match_status.group(1), "test": test.strip(), "reason": reason.strip()}

    # 匹配简略格式：只有 "ERROR/FAILED 文件路径"
    match_simple = match_status
    if match_simple:
        return {
            "type": match_simple.group(1),
            "test": match_simple.group(2).strip(),
            "reason": "No detailed error message (likely collect/import failure)"
        }
    return None


def main():
    FAIL = "FAILED"
    ERROR = "ERROR"
    res = []
    file = sys.argv[1] or 'test_ds_v0.18.log'
    print(f"extract file {file}")
    with open(file, 'r', encoding='utf-8') as f:
        flag = False
        for line in f:
            if "short test summary info" in line:
                # print("start analyize......")
                flag = True
                continue
            # Only parse pytest summary entries.  Log bodies can contain words
            # such as "ERROR" or "FAILED" (compiler/NCCL output) that are not
            # summary records and must not enter the parser or debugger.
            summary_line = clean_ansi(line).strip()
            if re.match(r'^(FAILED|ERROR)\s+', summary_line) and flag:
                r = extract_test_error_or_failure(line)
                if r is not None:
                    res.append(r)
                continue
            if "test session starts" in line:
                flag = False

        # 转换为 DataFrame
        df = pd.DataFrame(res)

        print(df[:3])
        # 可选：调整列顺序
        df = df[["type", "test", "reason"]]

        # 导出为 Excel
        output_file = f"pytest_failures_and_errors_for{file}.xlsx"
        df.to_excel(output_file, index=False, sheet_name="Test Failures")

        print(f"✅ 已导出 {len(df)} 条记录到 {output_file}")


if __name__ == '__main__':
    main()
