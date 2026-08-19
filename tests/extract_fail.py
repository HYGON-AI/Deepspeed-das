# Copyright (c) 2026 Hygon Information Technology Co., Ltd.
# SPDX-License-Identifier: Apache-2.0

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
    
    # 匹配完整格式：有 "- 原因"
    match_full = re.match(r'^(ERROR|FAILED)\s+(.+?)\s*-\s*(.+)$', clean_line)
    if match_full:
        return {
            "type": match_full.group(1),
            "test": match_full.group(2).strip(),
            "reason": match_full.group(3).strip()
        }
    
    # 匹配简略格式：只有 "ERROR/FAILED 文件路径"
    match_simple = re.match(r'^(ERROR|FAILED)\s+(.+)$', clean_line)
    if match_simple:
        return {
            "type": match_simple.group(1),
            "test": match_simple.group(2).strip(),
            "reason": "No detailed error message (likely collect/import failure)"
        }
    else:
        try:
            raise ValueError(f"Invalid line format: {clean_line}")
        except ValueError as e:
            print(e)
            import pdb
            pdb.set_trace()
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
            if (FAIL in line or ERROR in line) and flag:
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
