#!/usr/bin/env python3

import sys
from pathlib import Path
from PIL import Image
import pytesseract


def run_ocr(image_path: Path, lang: str = "fra+eng") -> str:
    """
    Lance l'OCR sur une image et retourne le texte brut.
    Aucun raisonnement, aucune décision.
    """
    if not image_path.exists():
        raise FileNotFoundError(f"Image not found: {image_path}")

    image = Image.open(image_path)
    text = pytesseract.image_to_string(image, lang=lang)
    return text


if __name__ == "__main__":
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: ocr_image.py <image_path> [lang]")
        sys.exit(1)

    image_path = Path(sys.argv[1])
    lang = sys.argv[2] if len(sys.argv) == 3 else "fra+eng"

    result = run_ocr(image_path, lang=lang)
    print(result)

