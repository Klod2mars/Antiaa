#!/usr/bin/env python3
import sys
import json
import shutil
import hashlib
from datetime import datetime, UTC
from pathlib import Path


BASE_DIR = Path.home() / "cognitive-system"
INCOMING_TELEGRAM = (BASE_DIR / "INCOMING" / "telegram").resolve()
STOCK_FILES = BASE_DIR / "STOCK" / "files"
STOCK_PIECES = BASE_DIR / "STOCK" / "pieces"


def sha256_of_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def register_piece(source_path: Path, source: str = "telegram") -> Path:
    source_path = source_path.resolve()

    if not source_path.exists():
        raise FileNotFoundError(source_path)

    if INCOMING_TELEGRAM not in source_path.parents and source_path.parent !=INCOMING_TELEGRAM:
        raise ValueError(
            f"Le fichier doit provenir de {INCOMING_TELEGRAM}"
        )

    timestamp = datetime.now(UTC).strftime("%Y-%m-%dT%H-%M-%SZ")
    piece_id = f"{source}_{timestamp}"

    dest_file = STOCK_FILES / f"{piece_id}{source_path.suffix}"

    shutil.move(str(source_path), dest_file)

    piece = {
        "piece_id": piece_id,
        "type": "image",
        "source": source,
        "received_at": datetime.now(UTC).isoformat(),
        "file": {
            "path": str(dest_file.relative_to(BASE_DIR)),
            "hash": "sha256:" + sha256_of_file(dest_file),
            "mime": "image/" + source_path.suffix.lstrip("."),
            "size_bytes": dest_file.stat().st_size,
        },
        "status": "raw",
        "notes": ""
    }

    piece_json = STOCK_PIECES / f"{piece_id}.json"
    with piece_json.open("w", encoding="utf-8") as f:
        json.dump(piece, f, indent=2, ensure_ascii=False)

    return piece_json


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: register_piece.py INCOMING/telegram/<image>")
        sys.exit(1)

    source_path = Path(sys.argv[1]).expanduser()
    piece_json = register_piece(source_path)
    print(f"PIÈCE ENREGISTRÉE : {piece_json}")
import sys
import json
import shutil
import hashlib
from datetime import datetime
from pathlib import Path


BASE_DIR = Path.home() / "cognitive-system"
STOCK_FILES = BASE_DIR / "STOCK" / "files"
STOCK_PIECES = BASE_DIR / "STOCK" / "pieces"


def sha256_of_file(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()


def register_piece(source_path: Path, source: str = "manual") -> Path:
    if not source_path.exists():
        raise FileNotFoundError(source_path)

    timestamp = datetime.utcnow().strftime("%Y-%m-%dT%H-%M-%SZ")
    piece_id = f"{source}_{timestamp}"

    dest_file = STOCK_FILES / f"{piece_id}{source_path.suffix}"
    shutil.copy2(source_path, dest_file)

    piece = {
        "piece_id": piece_id,
        "type": "image",
        "source": source,
        "received_at": datetime.utcnow().isoformat() + "Z",
        "file": {
            "path": str(dest_file.relative_to(BASE_DIR)),
            "hash": "sha256:" + sha256_of_file(dest_file),
            "mime": "image/" + source_path.suffix.lstrip("."),
            "size_bytes": dest_file.stat().st_size,
        },
        "status": "raw",
        "notes": ""
    }

    piece_json = STOCK_PIECES / f"{piece_id}.json"
    with piece_json.open("w", encoding="utf-8") as f:
        json.dump(piece, f, indent=2, ensure_ascii=False)

    return piece_json


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python register_piece.py <image_path>")
        sys.exit(1)

    source_path = Path(sys.argv[1]).expanduser()
    piece_json = register_piece(source_path)
    print(f"Piece enregistrée : {piece_json}")
