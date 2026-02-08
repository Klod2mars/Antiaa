#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Antiaa / OpenClaw - COMMIT RÉEL
# - aucune écriture irréversible sans validation humaine explicite
# - append-only (pas d'écrasement)
# - traçabilité (hash, date, statut)
# - vérifiabilité immédiate (ls/cat)
# -------------------------------------------------------------------

VALIDATION_PHRASE="OK, le résumé est prêt, tu peux l’enregistrer."

usage() {
  cat <<'EOF'
Usage:
  OPERATIONS/commit_real_piece.sh \
    --piece <path_to_image> \
    --canon-file <path_to_canon_txt> \
    --status <green|yellow> \
    [--id <custom_id>] \
    [--confirm]

Notes:
  - Sans validation explicite (phrase exacte), aucune écriture n'a lieu.
  - --confirm : demande la phrase en interactif (obligatoire de toute façon).
  - Le canon est copié tel quel (pas de transformation).
  - Append-only: abort si les fichiers de destination existent déjà.

Exemples:
  OPERATIONS/commit_real_piece.sh --piece INCOMING/telegram/img_001.jpg --canon-file /tmp/canon.txt --status yellow --confirm
  OPERATIONS/commit_real_piece.sh --piece INCOMING/telegram/img_002.png --canon-file /tmp/canon.txt --status green --confirm

EOF
}

die() { echo "ERROR: $*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Commande requise manquante: $1"
}

json_escape() {
  # Escape minimal JSON: backslash, quotes, newlines, tabs
  python3 - <<'PY'
import sys
s = sys.stdin.read()
s = s.replace("\\","\\\\").replace('"','\\"').replace("\n","\\n").replace("\t","\\t")
sys.stdout.write(s)
PY
}

# --- Preconditions ---
need_cmd sha256sum
need_cmd cp
need_cmd mkdir
need_cmd date
need_cmd stat
need_cmd python3

# --- Args parsing ---
PIECE_PATH=""
CANON_FILE=""
STATUS=""
CUSTOM_ID=""
DO_CONFIRM="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --piece) PIECE_PATH="${2:-}"; shift 2;;
    --canon-file) CANON_FILE="${2:-}"; shift 2;;
    --status) STATUS="${2:-}"; shift 2;;
    --id) CUSTOM_ID="${2:-}"; shift 2;;
    --confirm) DO_CONFIRM="true"; shift 1;;
    -h|--help) usage; exit 0;;
    *) die "Argument inconnu: $1";;
  esac
done

[[ -n "$PIECE_PATH" ]] || die "--piece requis"
[[ -n "$CANON_FILE" ]] || die "--canon-file requis"
[[ -n "$STATUS" ]] || die "--status requis (green|yellow)"
[[ "$STATUS" == "green" || "$STATUS" == "yellow" ]] || die "--status invalide: $STATUS"

[[ -f "$PIECE_PATH" ]] || die "Pièce introuvable: $PIECE_PATH"
[[ -f "$CANON_FILE" ]] || die "Canon introuvable: $CANON_FILE"

# --- Paths (architecture non modifiée) ---
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STOCK_DIR="$ROOT_DIR/STOCK/pieces"
SUM_DIR="$ROOT_DIR/INTERPRETATIONS/summaries"

mkdir -p "$STOCK_DIR" "$SUM_DIR"

# --- Build ID (append-only) ---
# ID stable: timestamp + sha256 prefix (anti-collision, traçable)
PIECE_HASH="$(sha256sum "$PIECE_PATH" | awk '{print $1}')"
HASH8="${PIECE_HASH:0:8}"
TS="$(date +"%Y%m%d_%H%M%S")"
ID="${CUSTOM_ID:-${TS}__${HASH8}}"

# --- Compute destination filenames ---
ORIG_BASENAME="$(basename "$PIECE_PATH")"
PIECE_DST="$STOCK_DIR/${ID}__${ORIG_BASENAME}"
CANON_DST="$SUM_DIR/${ID}.txt"
META_DST="$SUM_DIR/${ID}.meta.json"

# --- Hard "append-only" checks ---
[[ ! -e "$PIECE_DST" ]] || die "Destination pièce existe déjà (append-only): $PIECE_DST"
[[ ! -e "$CANON_DST" ]] || die "Destination canon existe déjà (append-only): $CANON_DST"
[[ ! -e "$META_DST" ]] || die "Destination metadata existe déjà (append-only): $META_DST"

# --- Explicit human validation gate ---
# Sans cette validation: rien n'est écrit.
echo "----------------------------------------------"
echo "GATE DE VALIDATION HUMAINE (obligatoire)"
echo "Pour autoriser l'écriture irréversible, tape EXACTEMENT:"
echo
echo "  $VALIDATION_PHRASE"
echo
read -r -p "Validation (copier/coller la phrase) > " USER_INPUT

if [[ "$USER_INPUT" != "$VALIDATION_PHRASE" ]]; then
  echo "VALIDATION REFUSÉE: phrase non exacte."
  echo "=> Rien n'a été enregistré."
  exit 2
fi

# --- COMMIT RÉEL (écritures physiques) ---
# 1) Copier physiquement la pièce
cp --no-clobber --preserve=mode,timestamps "$PIECE_PATH" "$PIECE_DST"

# 2) Écrire le canon validé (copie brute, zéro transformation)
cp --no-clobber --preserve=mode,timestamps "$CANON_FILE" "$CANON_DST"

# 3) Metadata (optionnel mais recommandé)
NOW_ISO="$(date -Iseconds)"
PIECE_SIZE="$(stat -c%s "$PIECE_DST")"
CANON_HASH="$(sha256sum "$CANON_DST" | awk '{print $1}')"

# JSON minimal, explicite, vérifiable
# (Pas d'appel réseau, pas d'agent, pas d'interprétation)
ORIG_PATH_ESCAPED="$(printf "%s" "$PIECE_PATH" | json_escape)"
ORIG_NAME_ESCAPED="$(printf "%s" "$ORIG_BASENAME" | json_escape)"

cat > "$META_DST" <<EOF
{
  "id": "$(printf "%s" "$ID" | json_escape)",
  "created_at": "$(printf "%s" "$NOW_ISO" | json_escape)",
  "status": "$(printf "%s" "$STATUS" | json_escape)",
  "original_path": "$ORIG_PATH_ESCAPED",
  "original_name": "$ORIG_NAME_ESCAPED",
  "piece": {
    "path": "$(printf "%s" "$PIECE_DST" | json_escape)",
    "sha256": "$(printf "%s" "$PIECE_HASH" | json_escape)",
    "size_bytes": $PIECE_SIZE
  },
  "canon": {
    "path": "$(printf "%s" "$CANON_DST" | json_escape)",
    "sha256": "$(printf "%s" "$CANON_HASH" | json_escape)"
  }
}
EOF

# --- Post-write verification (refuse to claim success if mismatch) ---
COPIED_HASH="$(sha256sum "$PIECE_DST" | awk '{print $1}')"
if [[ "$COPIED_HASH" != "$PIECE_HASH" ]]; then
  echo "ERREUR CRITIQUE: hash de la copie ne matche pas l'original."
  echo "Original: $PIECE_HASH"
  echo "Copie   : $COPIED_HASH"
  echo "=> Commit invalide (les fichiers existent, mais la vérification échoue)."
  exit 3
fi

# --- Fact-based confirmation (verifiable) ---
echo "----------------------------------------------"
echo "STOCKÉE (vérifiable sur disque) ✅"
echo
echo "Pièce copiée vers:"
echo "  $PIECE_DST"
echo
echo "Canon écrit vers:"
echo "  $CANON_DST"
echo
echo "Metadata écrit vers:"
echo "  $META_DST"
echo
echo "Vérification immédiate (à lancer):"
echo "  ls -la \"$PIECE_DST\" \"$CANON_DST\" \"$META_DST\""
echo "  sha256sum \"$PIECE_DST\""
echo "  head -n 40 \"$CANON_DST\""
echo "  cat \"$META_DST\""
echo "----------------------------------------------"
