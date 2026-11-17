#!/usr/bin/env bash
# Build the FunctionGraph deployment package from source.
# The output zip is a build artifact and is intentionally gitignored.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/src/nlp_inference.py"
OUT="$ROOT/src/nlp_inference.zip"
STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

cp "$SRC" "$STAGE/nlp_inference.py"
python -m pip install --quiet --target "$STAGE" requests

python - "$STAGE" "$OUT" <<'PY'
import os, sys, zipfile
stage, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, dirs, files in os.walk(stage):
        for f in files:
            full = os.path.join(root, f)
            z.write(full, os.path.relpath(full, stage))
PY
echo "built: $OUT"
