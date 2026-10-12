#!/usr/bin/env bash
# ------------------------------------------------------------------
# 修复 DTK 环境下 hcusmi 导入失败（KeyError: 'libhcu_smi.so'）
# 放置位置：CI 中「python -c "import torch"」这一步之前
#
# 依据 hcusmi_wrapper.py 的真实逻辑：
#   find_hcusmi_library() 依次尝试 5 个位置，全部失败才抛异常，
#   且只保留最后一个（= cwd 那个），因此原报错信息具有误导性：
#     0) <site-packages 上溯4级>/lib/libhcu_smi.so
#     1) ${ROCM_HOME|ROCM_PATH}/lib/libhcu_smi.so   （变量未设则跳过）
#     2) libhcu_smi.so（裸名，走 LD_LIBRARY_PATH / ld.so.cache）
#     3) <hcusmi 包目录>/libhcu_smi.so
#     4) $PWD/libhcu_smi.so
#
# 排障顺序：先证文件存在，再填最容易命中的候选位置。
# ------------------------------------------------------------------
set -euo pipefail

HCUSMI_DIR=$(python3 -c "import sysconfig,os; print(os.path.join(sysconfig.get_paths()['purelib'],'hcusmi'))")
echo "HCUSMI_DIR = ${HCUSMI_DIR}"

echo "===== [1/4] 在 runner 上确认 .so 是否真实存在（-type f 排除断链） ====="
SO=$(find / -name 'libhcu_smi.so*' -type f -size +0c 2>/dev/null | head -n1 || true)
if [ -z "${SO}" ]; then
  echo "!! 本机（CI runner）上不存在 libhcu_smi.so —— 这才是根因，做软链是无效的。"
  echo "-- 已装的相关 rpm --"; rpm -qa 2>/dev/null | grep -i -E 'hcusmi|hcu-smi' || echo "(无)"
  echo "-- DTK 包内候选 --";  tar tzf "${DTK_PKG:-/dev/null}" 2>/dev/null | grep -i hcusmi || echo "(未找到)"
  echo "-- 系统内候选 rpm --"; find / -maxdepth 5 -name '*hcusmi*.rpm' 2>/dev/null || true
  echo ">> 解决：安装系统包 hcusmi-lib，或安装一个自带 .so 的 hcusmi wheel。"
  exit 1
fi
echo "SO = ${SO}"; ls -l "${SO}"

echo "===== [2/4] 与 wrapper 完全一致的逐候选取证 ====="
SO_PATH="${SO}" HCUSMI_DIR="${HCUSMI_DIR}" python3 - <<'PY'
import os, ctypes
from pathlib import Path
name = "libhcu_smi.so"
f = (Path(os.environ["HCUSMI_DIR"]) / "hcusmi_wrapper.py").resolve()
cands = [
    f.parent.parent.parent.parent / "lib" / name,
    os.path.join(os.getenv("ROCM_HOME") or os.getenv("ROCM_PATH") or "<未设置>", "lib", name),
    name,
    f.parent / name,
    Path.cwd() / name,
]
for c in cands:
    try:
        ctypes.CDLL(str(c)); r = "OK  <== 命中"
    except OSError as e:
        r = f"FAIL: {e}"
    print(f"exists={os.path.exists(str(c))!s:5s} {str(c):72s} {r}")
PY

echo "===== [3/4] 填充候选位置（按可靠性排序） ====="
# 3a. 最优：拷进包目录（候选 3），与 .so 同源、随包走
cp -f "${SO}" "${HCUSMI_DIR}/"
echo "-> ${HCUSMI_DIR}/$(basename "${SO}")"

# 3b. 次优：通过 ROCM_HOME 命中候选 1（该变量不设则候选 1 会被跳过）
export ROCM_HOME="$(dirname "$(dirname "${HCUSMI_DIR}")")"   # 一般为 /usr/local
mkdir -p "${ROCM_HOME}/lib"
cp -f "${SO}" "${ROCM_HOME}/lib/$(basename "${SO}")"
echo "-> ${ROCM_HOME}/lib/$(basename "${SO}")  (ROCM_HOME=${ROCM_HOME})"

# 3c. 兜底：注册进系统库目录 + 包目录进 LD_LIBRARY_PATH（覆盖候选 2）
cp -f "${SO}" "/usr/local/lib/$(basename "${SO}")" 2>/dev/null || true
echo /usr/local/lib > /etc/ld.so.conf.d/hcusmi.conf 2>/dev/null || true
ldconfig 2>/dev/null || true
export LD_LIBRARY_PATH="${HCUSMI_DIR}:${LD_LIBRARY_PATH:-}"

echo "===== [4/4] 验证 ====="
python3 -c "import ctypes; ctypes.CDLL('${SO}'); print('dlopen 源文件 -> OK')"
python3 -c "import hcusmi; print('import hcusmi -> OK')"
python3 -c "import torch; print('import torch -> OK', torch.__version__)"
echo "===== 修复完成 ====="