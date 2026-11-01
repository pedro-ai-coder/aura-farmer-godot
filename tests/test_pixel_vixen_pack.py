"""Resource-contract fixtures only; no substitute artwork is shown or shipped."""
import hashlib
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from verify_pixel_vixen import ASSETS, DIRECTORY, validate, validate_pack

class PixelVixenPackTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.folder = self.root / DIRECTORY
        self.folder.mkdir(parents=True)
        self.manifest = {"hero_id": "sigma", "appearance": "female",
                         "status": "UNAPPROVED_CREATOR_REVIEW_CANDIDATE", "runtime_authorization": "PREVIEW_ONLY"}
        for field, checksum, dimensions, name, size in ASSETS:
            # A binary-header unit fixture, never a runtime sprite/portrait.
            data = b"\x89PNG\r\n\x1a\n" + struct.pack(">I", 13) + b"IHDR" + struct.pack(">II", *size) + b"\x08\x06\x00\x00\x00" + bytes(4)
            (self.folder / name).write_bytes(data)
            self.manifest.update({field: name, checksum: hashlib.sha256(data).hexdigest(), dimensions: list(size)})
        self.write_manifest()

    def write_manifest(self):
        (self.folder / "manifest.json").write_text(json.dumps(self.manifest))

    def test_missing_assets_fail_together(self):
        for _, _, _, name, _ in ASSETS:
            (self.folder / name).unlink()
        with self.assertRaisesRegex(ValueError, "atlas-v2.*portrait-v2.*hud-v2"):
            validate(self.root)

    def test_source_hash_and_dimensions_are_required(self):
        path = self.folder / ASSETS[0][3]
        data = bytearray(path.read_bytes());data[16] ^= 1;path.write_bytes(data)
        with self.assertRaisesRegex(ValueError, "SHA-256"):
            validate(self.root)
        self.manifest["atlas_sha256"] = hashlib.sha256(data).hexdigest();self.write_manifest()
        with self.assertRaisesRegex(ValueError, "dimensions/header"):
            validate(self.root)

    def test_pack_requires_all_three_textures_and_manifest(self):
        sources = validate(self.root)
        paths = [(DIRECTORY / "manifest.json").as_posix()]
        for source in sources:
            paths.extend([source + ".import", ".godot/imported/" + Path(source).name + "-test.ctex"])
        validate_pack(paths, sources)
        with self.assertRaisesRegex(ValueError, "missing"):
            validate_pack(paths[:-1], sources)
        with self.assertRaisesRegex(ValueError, "V1"):
            validate_pack(paths + ["assets/art-candidates/pixel-vixen/v1/atlas.png.import"], sources)

    def test_candidate_cannot_be_promoted_by_manifest(self):
        self.manifest["status"] = "APPROVED";self.write_manifest()
        with self.assertRaisesRegex(ValueError, "preview-only"):
            validate(self.root)

if __name__ == "__main__":
    unittest.main()
