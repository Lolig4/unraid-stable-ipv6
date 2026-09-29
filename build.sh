#!/usr/bin/env bash
# Assembles stable-ipv6.plg from the template and the files in files/.
# The template carries the plugin metadata and the FILE declarations, the
# @@name@@ markers are replaced with the contents of files/name.
set -euo pipefail
cd "$(dirname "$(realpath "$0")")"

OUT=stable-ipv6.plg
python3 - "$OUT" <<'PY'
import io, os, re, sys
out = sys.argv[1]
tmpl = io.open("stable-ipv6.plg.in", encoding="utf-8").read()

def fill(m):
    path = os.path.join("files", m.group(1))
    if not os.path.isfile(path):
        sys.exit("missing: " + path)
    # The marker sits on its own line, so the template already supplies the
    # surrounding newlines.
    return io.open(path, encoding="utf-8").read().rstrip("\n")

result = re.sub(r"@@([^@\n]+)@@", fill, tmpl)
left = re.findall(r"@@[^@\n]+@@", result)
if left:
    sys.exit("unreplaced markers: " + ", ".join(left))
io.open(out, "w", encoding="utf-8").write(result)
PY

# A broken plugin file is worse than none, so check before handing it over.
python3 -c "import xml.dom.minidom,sys; xml.dom.minidom.parse('$OUT')" || exit 1
for F in files/stable-ipv6 files/apply files/hook-install.sh files/hook-remove.sh; do
    bash -n "$F" || exit 1
done
command -v php >/dev/null && php -l <(sed -n '/^---$/,$p' files/StableIPv6.page | tail -n +2) >/dev/null

echo "built $OUT ($(wc -l < "$OUT") lines)"
