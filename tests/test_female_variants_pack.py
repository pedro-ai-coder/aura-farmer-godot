"""Negative resource-contract tests; header fixtures are never runtime art."""
import hashlib
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1]/"scripts"))
from verify_female_variants import VARIANTS, STATES, KINDS, validate, validate_pack

class FemalePackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for slug, (hero_id, name) in VARIANTS.items():
            folder = self.root/"assets/art-candidates"/slug/"v2"
            folder.mkdir(parents=True)
            m = {"hero_id":hero_id,"appearance":"female","display_name":name,"asset_slug":slug,
                 "status":"UNAPPROVED_CREATOR_REVIEW_CANDIDATE","runtime_authorization":"PREVIEW_ONLY",
                 "states":STATES,"frame_count":24,"world_scale":0.25,"frame_geometry":"frames.json"}
            for suffix,key,size in KINDS:
                n=f"{slug}-{suffix}-v2.png"
                data=b"\x89PNG\r\n\x1a\n"+struct.pack(">I",13)+b"IHDR"+struct.pack(">II",*size)+b"\x08\x06\x00\x00\x00"+bytes(4)
                (folder/n).write_bytes(data)
                m[key]=n;m["hud_dimensions" if suffix=="hud" else key+"_dimensions"]=list(size)
                m["hud_sha256" if suffix=="hud" else key+"_sha256"]=hashlib.sha256(data).hexdigest()
            data=json.dumps([{"source_rect":[0,0,8,8],"pivot":[4,7],"mask_rects":[[0,0,8,8]]}]*24).encode()
            (folder/"frames.json").write_bytes(data);m["frame_geometry_sha256"]=hashlib.sha256(data).hexdigest()
            (folder/"manifest.json").write_text(json.dumps(m))

    def test_every_missing_png_fails_closed(self):
        for slug in VARIANTS:
            for suffix,_,_ in KINDS:
                p=self.root/f"assets/art-candidates/{slug}/v2/{slug}-{suffix}-v2.png"
                data=p.read_bytes();p.unlink()
                with self.assertRaisesRegex(ValueError,"Missing required female asset"): validate(self.root)
                p.write_bytes(data)

    def test_wrong_art_and_geometry_are_rejected(self):
        p=self.root/"assets/art-candidates/byte-baddie/v2/byte-baddie-hud-v2.png"
        p.write_bytes(p.read_bytes()+b"wrong art")
        with self.assertRaisesRegex(ValueError,"SHA-256 mismatch"): validate(self.root)

    def test_export_requires_every_texture_and_metadata(self):
        sources,metadata=validate(self.root)
        paths=metadata.copy()
        for p in sources: paths.extend([p+".import",".godot/imported/"+Path(p).name+"-test.ctex"])
        validate_pack(paths,sources,metadata)
        for missing in paths:
            with self.assertRaisesRegex(ValueError,"Missing"): validate_pack([p for p in paths if p!=missing],sources,metadata)
        with self.assertRaisesRegex(ValueError,"V1"): validate_pack(paths+["assets/art-candidates/byte-baddie/v1/atlas.png.import"],sources,metadata)

    def test_new_hero_id_cannot_be_smuggled_in(self):
        p=self.root/"assets/art-candidates/block-queen/v2/manifest.json"
        m=json.loads(p.read_text());m["hero_id"]="block-queen";p.write_text(json.dumps(m))
        with self.assertRaisesRegex(ValueError,"canonical cosmetic identity"): validate(self.root)

if __name__ == "__main__": unittest.main()
