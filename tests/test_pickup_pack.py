"""Negative packaging contracts; fixtures are copied real candidate bytes."""
import json
from pathlib import Path
import shutil
import sys
import tempfile
import unittest
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/"scripts"))
from verify_pickup_candidates import ROOT, FOLDER, MANIFEST, validate, validate_pack

class PickupPackTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        shutil.copytree(ROOT/FOLDER,self.root/FOLDER)

    def test_every_missing_or_changed_asset_fails(self):
        for p in (self.root/FOLDER).rglob("*"):
            if p.suffix not in [".png",".svg"]:continue
            data=p.read_bytes();p.unlink()
            with self.assertRaisesRegex(ValueError,"Missing"):validate(self.root)
            p.write_bytes(data+b"wrong bytes")
            with self.assertRaisesRegex(ValueError,"SHA-256"):validate(self.root)
            p.write_bytes(data)

    def test_wrong_mapping_or_approval_is_rejected(self):
        p=self.root/MANIFEST;original=json.loads(p.read_text())
        for key,value in [("display_name","XP Crystal"),("kind","new-currency"),("runtime_path",FOLDER+"street-snack.png"),("world_extent",90)]:
            m=json.loads(json.dumps(original));m["resources"][0][key]=value;p.write_text(json.dumps(m))
            with self.assertRaisesRegex(ValueError,"mapping"):validate(self.root)
        m=original;m["status"]="APPROVED";p.write_text(json.dumps(m))
        with self.assertRaisesRegex(ValueError,"candidate"):validate(self.root)

    def test_every_texture_manifest_and_source_exclusion(self):
        textures=validate(self.root);paths=[MANIFEST]
        for p in textures:paths += [p+".import",".godot/imported/"+Path(p).name+"-test.ctex"]
        validate_pack(paths,textures)
        for missing in paths:
            with self.assertRaisesRegex(ValueError,"Missing"):validate_pack([p for p in paths if p!=missing],textures)
        for leaked in [FOLDER+"source/xp-orb.svg","tests/pickup_refresh/capture.gd"]:
            with self.assertRaisesRegex(ValueError,"must not ship"):validate_pack(paths+[leaked],textures)

if __name__=="__main__":unittest.main()
