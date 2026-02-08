#!/usr/bin/env bash
set -euo pipefail

# -------------------------------------------------------------------
# Antiaa / OpenClaw - COMMIT RÉEL (avec preuve de validation)
# - aucune écriture irréversible sans validation humaine explicite
# - append-only (pas d'écrasement)
# - traçabilité (hash, date, statut, validation)
# - écriture d'un log d'action vérifiable (LOGS/actions/<id>.action.json)
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
    [--confirm] \
    [--validator <validator_id>]

Notes:
  - Sans validation explicite (phrase exacte), aucune écriture n'a lieu.
  - --confirm : demande la phrase en interactif (obligatoire de toute façon).
  - Le canon est copié tel quel (pas de transformation).
  - Append-only: abort si les fichiers de destination existent déjà.
  - --validator : optionnel, permet de fournir l'identité du validateur.
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
OVERRIDE_VALIDATOR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --piece) PIECE_PATH="${2:-}"; shift 2;;
    --canon-file) CANON_FILE="${2:-}"; shift 2;;
    --status) STATUS="${2:-}"; shift 2;;
    --id) CUSTOM_ID="${2:-}"; shift 2;;
    --confirm) DO_CONFIRM="true"; shift 1;;
    --validator) OVERRIDE_VALIDATOR="${2:-}"; shift 2;;
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
LOGS_ACTIONS_DIR="$ROOT_DIR/LOGS/actions"

mkdir -p "$STOCK_DIR" "$SUM_DIR" "$LOGS_ACTIONS_DIR"

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
ACTION_DST="$LOGS_ACTIONS_DIR/${ID}.action.json"

# --- Hard "append-only" checks ---
[[ ! -e "$PIECE_DST" ]] || die "Destination pièce existe déjà (append-only): $PIECE_DST"
[[ ! -e "$CANON_DST" ]] || die "Destination canon existe déjà (append-only): $CANON_DST"
[[ ! -e "$META_DST" ]] || die "Destination metadata existe déjà (append-only): $META_DST"
[[ ! -e "$ACTION_DST" ]] || die "Destination action log existe déjà (append-only): $ACTION_DST"

# --- Explicit human validation gate ---
# Sans cette validation: rien n'est écrit.
echo "----------------------------------------------"
echo "GATE DE VALIDATION HUMAINE (obligatoire)"
echo "Pour autoriser l'écriture irréversible, tape EXACTEMENT:"
echo
echo "  $VALIDATION_PHRASE"
echo

if [[ "$DO_CONFIRM" == "true" ]]; then
  read -r -p "Validation (copier/coller la phrase) > " USER_INPUT
else
  # force interactive confirmation if not provided
  read -r -p "Validation (copier/coller la phrase) > " USER_INPUT
fi

if [[ "$USER_INPUT" != "$VALIDATION_PHRASE" ]]; then
  echo "VALIDATION REFUSÉE: phrase non exacte."
  echo "=> Rien n'a été enregistré."
  exit 2
fi

# --- Obtain validator identity ---
if [[ -n "$OVERRIDE_VALIDATOR" ]]; then
  VALIDATOR_ID="$OVERRIDE_VALIDATOR"
else
  # prefer git user.name if available
  if command -v git >/dev/null 2>&1; then
    VALIDATOR_ID="$(git config user.name || true)"
  fi
  if [[ -z "$VALIDATOR_ID" ]]; then
    read -r -p "Validator ID (nom ou identifiant) > " VALIDATOR_ID
  else
    # confirm default
    read -r -p "Validator ID [$VALIDATOR_ID] (Enter pour accepter ou taper autre) > " _TMP
    if [[ -n "$_TMP" ]]; then
      VALIDATOR_ID="$_TMP"
    fi
  fi
fi

# Method of validation
VALIDATION_METHOD="gate"

# --- COMMIT RÉEL (écritures physiques) ---
# 1) Copier physiquement la pièce
cp --no-clobber --preserve=mode,timestamps "$PIECE_PATH" "$PIECE_DST"

# 2) Écrire le canon validé (copie brute, zéro transformation)
cp --no-clobber --preserve=mode,timestamps "$CANON_FILE" "$CANON_DST"

# 3) Metadata (optionnel mais recommandé)
NOW_ISO="$(date -Iseconds)"
PIECE_SIZE="$(stat -c%s "$PIECE_DST")"
CANON_HASH="$(sha256sum "$CANON_DST" | awk '{print $1}')"

# Prepare escaped fields for JSON
ORIG_PATH_ESCAPED="$(printf "%s" "$PIECE_PATH" | json_escape)"
ORIG_NAME_ESCAPED="$(printf "%s" "$ORIG_BASENAME" | json_escape)"
PIECE_DST_ESCAPED="$(printf "%s" "$PIECE_DST" | json_escape)"
PIECE_HASH_ESCAPED="$(printf "%s" "$PIECE_HASH" | json_escape)"
CANON_DST_ESCAPED="$(printf "%s" "$CANON_DST" | json_escape)"
CANON_HASH_ESCAPED="$(printf "%s" "$CANON_HASH" | json_escape)"
VALIDATOR_ESCAPED="$(printf "%s" "$VALIDATOR_ID" | json_escape)"
NOW_ISO_ESCAPED="$(printf "%s" "$NOW_ISO" | json_escape)"
STATUS_ESCAPED="$(printf "%s" "$STATUS" | json_escape)"
META_DST_ESCAPED="$(printf "%s" "$META_DST" | json_escape)"
ACTION_DST_ESCAPED="$(printf "%s" "$ACTION_DST" | json_escape)"

# JSON minimal, explicite, vérifiable, avec bloc validation
cat > "$META_DST" <<EOF
{
  "id": "$(printf "%s" "$ID" | json_escape)",
  "created_at": "$NOW_ISO_ESCAPED",
  "status": "$STATUS_ESCAPED",
  "original_path": "$ORIG_PATH_ESCAPED",
  "original_name": "$ORIG_NAME_ESCAPED",
  "piece": {
    "path": "$PIECE_DST_ESCAPED",
    "sha256": "$PIECE_HASH_ESCAPED",
    "size_bytes": $PIECE_SIZE
  },
  "canon": {
    "path": "$CANON_DST_ESCAPED",
    "sha256": "$CANON_HASH_ESCAPED"
  },
  "validation": {
    "validator_id": "$VALIDATOR_ESCAPED",
    "timestamp": "$NOW_ISO_ESCAPED",
    "method": "$(printf "%s" "$VALIDATION_METHOD" | json_escape)",
    "reference": "$ACTION_DST_ESCAPED"
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

# --- Write action log (fact-based, verifiable) ---
ACTION_ID="${ID}__commit"
# Create action JSON
cat > "$ACTION_DST" <<EOF
{
  "action_id": "$(printf "%s" "$ACTION_ID" | json_escape)",
  "action_type": "commit_real_piece",
  "piece_id": "$(printf "%s" "$ID" | json_escape)",
  "validator": "$VALIDATOR_ESCAPED",
  "timestamp": "$NOW_ISO_ESCAPED",
  "meta_path": "$META_DST_ESCAPED",
  "verification": {
    "piece_sha256": "$PIECE_HASH_ESCAPED",
    "canon_sha256": "$CANON_HASH_ESCAPED"
  },
  "notes": ""
}
EOF

# Ensure written
if [[ ! -f "$ACTION_DST" ]]; then
  echo "ERREUR: impossible d'écrire l'action log : $ACTION_DST"
  exit 5
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
echo "Action log écrit vers:"
echo "  $ACTION_DST"
echo
echo "Vérification immédiate (à lancer):"
echo "  ls -la \"$PIECE_DST\" \"$CANON_DST\" \"$META_DST\""
echo "  sha256sum \"$PIECE_DST\""
echo "  head -n 40 \"$CANON_DST\""
echo "  cat \"$META_DST\""
echo "----------------------------------------------"
