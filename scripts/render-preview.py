"""Render the exported PDF for browsers without native inline PDF support."""
import json
import sys
from pathlib import Path
from pdf2image import convert_from_path
from pypdf import PdfReader

source, output = map(Path, sys.argv[1:3])
output.mkdir(parents=True, exist_ok=True)
reader = PdfReader(source)
pages = convert_from_path(source, dpi=150, poppler_path=sys.argv[3] if len(sys.argv)>3 and sys.argv[3] else None)
for i, image in enumerate(pages, 1):
    image.save(output / f'page-{i}.webp', 'WEBP', quality=90)
texts = [(p.extract_text() or '') for p in reader.pages]
(output / 'text.json').write_text(json.dumps(texts, ensure_ascii=False), encoding='utf-8')
