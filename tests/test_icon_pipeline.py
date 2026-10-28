"""Approval fixtures are temporary synthetic records, never creator authorization."""
import json
from pathlib import Path
import struct
import sys
import tempfile
import unittest

REPO=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(REPO/'scripts'))
import promote_approved_icons as pipeline
from check_icon_pack import inspect

class ApprovalPipeline(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root=Path(self.temp.name)
        for file in ['docs/art/v5_icon_readiness.json','docs/art/icon_approvals.json','assets/runtime-icons/manifest.json','assets/art-production/.gdignore','export_presets.cfg','assets/art-production/character-hype-clean-cut/v1/manifests/ASSET_MANIFEST.json','assets/art-production/character-hype-clean-cut/v1/weapons/ratio-blaster/icon-v5-candidate.png']:
            path=self.root/file;path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes((REPO/file).read_bytes())
        self.ledger([])
        (self.root/'assets/runtime-icons/manifest.json').write_text(json.dumps(dict(schema_version=1,icons=[])))
        source='assets/art-production/character-hype-clean-cut/v1/weapons/ratio-blaster/icon-v5-candidate.png'
        self.approval=dict(id='ratio-blaster',category='weapon',artwork_version='v5-candidate',source_path=source,source_sha256=pipeline.digest(self.root/source),approval_status='CREATOR_APPROVED',approval_reference='TEST FIXTURE ONLY — no real creator approval',remaining_conditions=[])
    def ledger(self,rows):
        (self.root/'docs/art/icon_approvals.json').write_text(json.dumps(dict(schema_version=1,approvals=rows)))
    def test_pending_and_conditions_never_copy(self):
        for change in [dict(approval_status='PRODUCTION_CANDIDATE'),dict(approval_reference=''),dict(remaining_conditions=['creator must choose']),dict(remaining_conditions=None)]:
            self.ledger([self.approval|change])
            with self.assertRaises(ValueError):pipeline.promote(self.root)
            self.assertEqual(list((self.root/'assets/runtime-icons').rglob('*.png')),[])
    def test_exact_immutable_copy_and_hash_revalidation(self):
        self.ledger([self.approval]);rows=pipeline.promote(self.root)
        path=self.root/rows[0]['resource_path'][6:]
        self.assertEqual(path.read_bytes(),(self.root/self.approval['source_path']).read_bytes())
        self.assertEqual(pipeline.validate(self.root),rows)
        path.write_bytes(b'changed')
        with self.assertRaises(ValueError):pipeline.validate(self.root)
        with self.assertRaises(ValueError):pipeline.promote(self.root)
    def test_ids_category_version_source_and_duplicates(self):
        for rows in [[self.approval|dict(category='passive')],[self.approval|dict(id='unknown')],[self.approval|dict(artwork_version='clean-cut-v2')],[self.approval|dict(source_path='../candidate.png')],[self.approval|dict(source_sha256='0'*64)],[self.approval,self.approval]]:
            self.ledger(rows)
            with self.assertRaises(ValueError):pipeline.promote(self.root)
    def test_empty_manifest_and_stray_files(self):
        self.assertEqual(pipeline.validate(self.root),[])
        (self.root/'assets/runtime-icons/unsigned.png').write_bytes(b'unsigned')
        with self.assertRaises(ValueError):pipeline.validate(self.root)
    def test_stale_unsigned_import_sidecar_rejected(self):
        (self.root/'assets/runtime-icons/unsigned.png.import').write_text('stale imported texture')
        with self.assertRaises(ValueError):pipeline.validate(self.root)
    def test_all_platform_isolation(self):
        (self.root/'export_presets.cfg').write_text((self.root/'export_presets.cfg').read_text().replace('assets/art-production/*','',1))
        with self.assertRaises(ValueError):pipeline.validate(self.root)

def pack(paths):
    header=bytearray(112);header[:4]=b'GDPC';struct.pack_into('<I',header,4,4);struct.pack_into('<Q',header,32,112)
    directory=struct.pack('<I',len(paths))
    for path in paths:
        encoded=path.encode();encoded+=b'\0'*((-len(encoded))%4)
        directory+=struct.pack('<I',len(encoded))+encoded+bytes(36)
    return bytes(header)+directory

class ExportIsolation(unittest.TestCase):
    def test_candidate_directory_and_imports_rejected(self):
        for path in ['assets/art-production/source.png.import','.godot/imported/icon-v5-candidate.png-hash.ctex','docs/art/evidence/clean-cut-review/sheet.jpg','tests/review_recovery_performance.gdc','tests/test_clean_cut_secondary_input.gd.remap']:
            with self.assertRaises(ValueError):inspect(pack([path]),[])
    def test_promoted_texture_requires_both_remap_and_import(self):
        row=dict(resource_path='res://assets/runtime-icons/weapons/ratio-blaster/'+'a'*64+'.png',promoted_sha256='a'*64)
        paths=[row['resource_path'][6:]+'.import','.godot/imported/'+'a'*64+'.png-enginehash.ctex']
        self.assertEqual(inspect(pack(paths),[row])['approved_icon_count'],1)
        with self.assertRaises(ValueError):inspect(pack(paths[:1]),[row])
    def test_unregistered_runtime_export_rejected(self):
        for path in ['assets/runtime-icons/unsigned.png.import','.godot/imported/'+'b'*64+'.png-enginehash.ctex']:
            with self.assertRaises(ValueError):inspect(pack([path]),[])
    def test_original_master_and_animation_metadata_required(self):
        paths=['assets/approved/sigma.png.import','.godot/imported/sigma.png-enginehash.ctex','assets/approved-enemy-frames.json']
        inspect(pack(paths),[],['assets/approved/sigma.png'],True)
        with self.assertRaises(ValueError):inspect(pack(paths[1:]),[],['assets/approved/sigma.png'],True)
        with self.assertRaises(ValueError):inspect(pack(paths[:-1]),[],['assets/approved/sigma.png'],True)
    def test_clean_pack_and_bad_format(self):
        self.assertEqual(inspect(pack(['assets/runtime-icons/manifest.json']),[])['candidate_entries'],0)
        with self.assertRaises(ValueError):inspect(b'WRONG'+bytes(100),[])

if __name__=='__main__':unittest.main()
