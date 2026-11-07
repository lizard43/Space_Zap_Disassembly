#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
echo "Space Zap ROM build"
echo "Input: Space_Zap_Disassembly.asm"
asm_version="$(sed -n '10s/^; RE version: //p' Space_Zap_Disassembly.asm)"
[[ "$asm_version" =~ ^v[0-9]{8}-[0-9]{4}$ ]] || { echo "ERROR: ASM version missing at header line 10" >&2; exit 1; }
echo "ASM: $asm_version"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Commit: $(git rev-parse --short HEAD)"
fi
echo
if [[ -x tools/zmac ]]; then ZMAC_BIN=./tools/zmac
elif [[ -n "${ZMAC:-}" ]]; then ZMAC_BIN="$ZMAC"
elif command -v zmac >/dev/null; then ZMAC_BIN="$(command -v zmac)"
else echo "ERROR: zmac missing. Use ZMAC=/path/to/zmac or tools/zmac." >&2; exit 1
fi
mkdir -p roms
echo "[1/4] Assemble the 16 KB program image"
echo "+ $ZMAC_BIN -o Space_Zap_Disassembly.bin Space_Zap_Disassembly.asm"
"$ZMAC_BIN" -o Space_Zap_Disassembly.bin Space_Zap_Disassembly.asm
IMAGE=Space_Zap_Disassembly.bin
LISTING=Space_Zap_Disassembly.lst
[[ -s "$IMAGE" && -s "$LISTING" ]] || { echo "ERROR: missing assembled image/listing" >&2; exit 1; }
image_size="$(wc -c < "$IMAGE")"
if [[ "$image_size" -ne 16384 ]]; then
    echo "ERROR: assembled image is ${image_size} bytes (expected 16384)" >&2
    if [[ -s roms/0662.01 && -s roms/0663.xx && -s roms/0664.xx && -s roms/0665.xx ]]; then
        echo "First differences from original ROM set (byte offset, assembled octal, original octal):" >&2
        cmp -l "$IMAGE" <(cat roms/0662.01 roms/0663.xx roms/0664.xx roms/0665.xx) | head -n 10 >&2 || true
    fi
    exit 1
fi
echo "Created: $IMAGE"
echo "Created: $LISTING"
echo
echo "[2/4] Split the image into four 4 KB ROMs"
names=(0662.01 0663.xx 0664.xx 0665.xx)
for i in 0 1 2 3; do
    dd if="$IMAGE" of="roms/${names[i]}" bs=4096 skip="$i" count=1 status=none
    [[ "$(wc -c < "roms/${names[i]}")" -eq 4096 ]] || { echo "ERROR: invalid ROM size" >&2; exit 1; }
    echo "Created: roms/${names[i]}"
done
echo
echo "[3/4] Package the MAME ROM set"
rm -f roms/spacezap.zip
(cd roms && zip -q -X spacezap.zip "${names[@]}")
echo "Created: roms/spacezap.zip"
echo
echo "[4/4] Verify official ROM SHA-1"
expected=(784ac67c75c7c101f97ebfd39b2b3f7bf7fa470a ad0e8c34a209c827c1336f0250cc61fee667fb03 72151e773562da62acd2c1d9638711711cbc13a3 5aabd720a106158a892368c4920d9cd0f5235e34)
failed=0
for i in 0 1 2 3; do
    actual="$(sha1sum "roms/${names[i]}" | cut -d' ' -f1)"
    printf '%s  roms/%s\n' "$actual" "${names[i]}"
    if [[ "$actual" != "${expected[i]}" ]]; then
        echo "WARNING: SHA-1 mismatch for ${names[i]} (expected ${expected[i]})"
        failed=1
    fi
done
if (( failed )); then echo "Build failed ROM verification."; exit 1; fi
echo "PASS: All generated ROMs match the official Space Zap SHA-1 values."
echo
echo "Build complete: roms/spacezap.zip"
