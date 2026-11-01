import json,shutil,sys,tempfile,unittest
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'scripts'))
from verify_weapon_presence import ROOT,FOLDER,MANIFEST,validate,validate_pack
class WeaponPresencePack(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory();self.addCleanup(self.temp.cleanup);self.root=Path(self.temp.name)
        shutil.copytree(ROOT/FOLDER,self.root/FOLDER)
        for path in ['assets/runtime-icons','scripts/weapon_attachments.gd']:
            source=ROOT/path;target=self.root/path;target.parent.mkdir(parents=True,exist_ok=True)
            if source.is_dir():shutil.copytree(source,target)
            else:shutil.copyfile(source,target)
    def test_missing_changed_and_wrong_art_are_rejected(self):
        m=json.loads((self.root/MANIFEST).read_text())
        paths=[r[k] for r in m['resources'] for k in ['path','source_path']]+[m['reused_approved_icons'][0]['path'],m['attachment_source']]
        for path in paths:
            p=self.root/path;data=p.read_bytes();p.write_bytes(data+b'changed')
            with self.assertRaises(ValueError):validate(self.root)
            p.write_bytes(data)
        p=self.root/m['resources'][0]['path'];p.unlink()
        with self.assertRaisesRegex(ValueError,'Missing'):validate(self.root)
    def test_every_exported_texture_and_manifest_is_required(self):
        textures=validate(self.root);paths=[MANIFEST]
        for p in textures:paths += [p+'.import','.godot/imported/'+Path(p).name+'-example.ctex']
        validate_pack(paths,textures)
        for missing in paths:
            with self.assertRaisesRegex(ValueError,'Missing'):validate_pack([p for p in paths if p!=missing],textures)
        with self.assertRaisesRegex(ValueError,'leaked'):validate_pack(paths+['tests/weapon_presence/review_run.gd'],textures)
    def test_art_approval_cannot_be_inferred(self):
        p=self.root/MANIFEST;m=json.loads(p.read_text());m['status']='APPROVED';p.write_text(json.dumps(m))
        with self.assertRaisesRegex(ValueError,'candidate'):validate(self.root)
if __name__=='__main__':unittest.main()
