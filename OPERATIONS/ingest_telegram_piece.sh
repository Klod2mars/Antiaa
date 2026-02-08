#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: ingest_telegram_piece.sh <image_path>" >&2
  exit 2
fi

IMG="$1"

if [[ ! -f "$IMG" ]]; then
  echo "ERROR: file not found: $IMG" >&2
  exit 2
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OCR="$ROOT/OPERATIONS/tools/ocr/ocr_image.py"

echo
echo "=============================="
echo "ANTIAA — OCR (TEXTE BRUT)"
echo "Fichier : $IMG"
echo "=============================="
echo

python3 "$OCR" "$IMG" fra

echo
echo "=============================="
echo "FIN OCR — AUCUNE ÉCRITURE FAITE"
echo "Copie ce texte dans Antiaa pour résumé canonique."
echo "=============================="
