#!/usr/bin/env python3
"""Reproduce committed SIL-OFL Inter UI instances; requires fonttools, not a CI dependency."""
from pathlib import Path
from urllib.request import urlopen
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
from fontTools import subset
import hashlib, io, json
SOURCE = 'https://raw.githubusercontent.com/google/fonts/0b58fb370093f9a9f4ff785d94405710b79de67c/ofl/inter/'
ROOT = Path(__file__).resolve().parents[1] / 'assets/fonts'

def main():
    raw = urlopen(SOURCE+'Inter%5Bopsz,wght%5D.ttf').read()
    license_bytes = urlopen(SOURCE+'OFL.txt').read()
    ROOT.mkdir(exist_ok=True)
    (ROOT/'OFL.txt').write_text('\n'.join(line.rstrip() for line in license_bytes.decode().splitlines())+'\n')
    manifest = {'source':SOURCE,'source_sha256':hashlib.sha256(raw).hexdigest(),'license':'SIL Open Font License 1.1','derivation':'Static weight/optical-size instances with Latin, punctuation and UI arrow/check subset; no outlines redrawn. Uncovered symbols use engine fallback.','files':[]}
    for name, weight, optical_size in [('Body',500,14),('Numbers',600,14),('Black',900,14),('Display',900,32)]:
        font = instantiateVariableFont(TTFont(io.BytesIO(raw)),{'wght':weight,'opsz':optical_size},inplace=False)
        options = subset.Options()
        options.name_IDs=['*']; options.name_legacy=True; options.name_languages=['*']; options.layout_features=['*']
        worker = subset.Subsetter(options=options)
        worker.populate(unicodes=list(range(0x20,0x250))+list(range(0x2000,0x2070))+list(range(0x2190,0x2200))+[0x2713,0x2715,0x2605,0x25cf])
        worker.subset(font)
        path = ROOT/f'Inter-{name}.ttf'
        font.save(path)
        manifest['files'].append({'path':path.name,'weight':weight,'optical_size':optical_size,'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
    (ROOT/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
if __name__ == '__main__': main()
