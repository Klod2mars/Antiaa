#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OPERATIONS/tools/register_piece.py
Enregistre une pièce (image/fichier) depuis INCOMING/ ou manuel vers STOCK,
crée une fiche JSON dans STOCK/pieces et écrit un log d'action dans LOGS/actions.

Usage:
  python3 register_piece.py <path_to_file> [--source telegram|manual] [--actor "Name"]

Notes:
  - Par défaut, source=telegram (déplace le fichier s'il vient de INCOMING/telegram).
  - Pour les sources manuelles, le fichier est copié (conserver l'original).
  - Le script échoue si la destination existe (append-only).
  - Le script écrit un log d'action JSON dans LOGS/actions/<piece_id>.action.json
"""

from __future__ import annotations
import sys
import json
import shutil
import hashlib
from datetime import datetime, timezone
from pathlib import Path
import argparse
import subprocess

# --- CONFIGURATION ---
ROOT_DIR = Path(__file__).resolve().parents[2]  # repo root (assume tools/ -> OPERATIONS/ -> repo)
INCOMING_TELEGRAM = (ROOT_DIR / "INCOMING" / "telegram").resolve()
STOCK_FILES = (ROOT_DIR / "STOCK" / "files").resolve()
STOCK_PIECES = (ROOT_DIR / "STOCK" / "pieces").resolve()
LOGS_ACTIONS = (ROOT_DIR / "LOGS" / "actions").resolve()

# ensure directories
for p in (STOCK_FILES, STOCK_PIECES, LOGS_ACTIONS):
    p.mkdir(parents=True, exist_ok=True)


def sha256_of_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def guess_mime_from_suffix(path: Path) -> str:
    suf = path.suffix.lower().lstrip(".")
    if suf in ("jpg", "jpeg", "png", "webp", "gif", "bmp", "tiff", "tif"):
        return f"image/{suf if suf!='jpg' else 'jpeg'}"
    if suf in ("pdf",):
        return "application/pdf"
    return f"application/octet-stream"


def git_user_name() -> str | None:
    try:
        out = subprocess.run(
            ["git", "config", "user.name"],
            cwd=ROOT_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            check=True,
            text=True,
        )
        name = out.stdout.strip()
        return name if name else None
    except Exception:
        return None


def register_piece(source_path: Path, source: str = "telegram", actor: str | None = None) -> Path:
    source_path = source_path.expanduser().resolve()
    if not source_path.exists():
        raise FileNotFoundError(f"Source introuvable: {source_path}")

    # If source is telegram, enforce that it comes from INCOMING_TELEGRAM if possible
    if source == "telegram":
        try:
            if INCOMING_TELEGRAM not in source_path.parents and source_path.parent != INCOMING_TELEGRAM:
                # allow but warn
                raise ValueError(
                    f"Le fichier semble ne pas provenir de {INCOMING_TELEGRAM}. "
                    "Si c'est intentionnel, utilisez --source manual."
                )
        except Exception as e:
            raise

    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H-%M-%SZ")
    piece_id = f"{source}_{timestamp}"

    dest_file = STOCK_FILES / f"{piece_id}{source_path.suffix}"

    # Append-only: fail if destination already exists
    if dest_file.exists():
        raise FileExistsError(dest_file)

    # Move for telegram, copy for manual (to preserve original)
    if source == "telegram":
        shutil.move(str(source_path), str(dest_file))
    else:
        shutil.copy2(str(source_path), str(dest_file))

    # compute hash and metadata
    file_hash = sha256_of_file(dest_file)
    size_bytes = dest_file.stat().st_size
    mime = guess_mime_from_suffix(dest_file)

    now_iso = datetime.now(timezone.utc).isoformat()

    # actor resolution
    actor_to_use = actor or git_user_name() or ""

    piece = {
        "piece_id": piece_id,
        "type": "file",
        "source": source,
        "received_at": now_iso,
        "actor": actor_to_use,
        "file": {
            "path": str(dest_file.relative_to(ROOT_DIR)),
            "hash": "sha256:" + file_hash,
            "mime": mime,
            "size_bytes": size_bytes,
        },
        "status": "raw",
        "notes": "",
    }

    piece_json = STOCK_PIECES / f"{piece_id}.json"
    if piece_json.exists():
        # Rare but safe: don't overwrite
        raise FileExistsError(piece_json)

    with piece_json.open("w", encoding="utf-8") as f:
        json.dump(piece, f, indent=2, ensure_ascii=False)

    # Write action log for traceability
    action = {
        "action_id": f"{piece_id}__register",
        "action_type": "register_piece",
        "piece_id": piece_id,
        "actor": actor_to_use,
        "timestamp": now_iso,
        "file": piece["file"],
        "status": piece["status"],
        "notes": "",
    }

    action_path = LOGS_ACTIONS / f"{piece_id}.action.json"
    if action_path.exists():
        raise FileExistsError(action_path)

    with action_path.open("w", encoding="utf-8") as f:
        json.dump(action, f, indent=2, ensure_ascii=False)

    # success
    print(f"PIÈCE ENREGISTRÉE : {piece_json}")
    print(f"ACTION LOG          : {action_path}")
    return piece_json


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Register a piece into STOCK and write action log")
    parser.add_argument("source_path", help="Path to the piece to register")
    parser.add_argument("--source", choices=["telegram", "manual"], default="telegram",
                        help="Origin of the piece (default: telegram)")
    parser.add_argument("--actor", default=None, help="Actor/validator name (optional)")
    args = parser.parse_args(argv)

    try:
        piece_json = register_piece(Path(args.source_path), source=args.source, actor=args.actor)
        return 0
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
