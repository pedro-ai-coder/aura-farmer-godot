"""Essential integrity contracts for the three preview-only CPK candidates."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def validate():
    for slug in ['byte-baddie','alpha-chad','block-queen']:
        folder=ROOT/'assets/art-candidates'/slug/'cpk-v1-proposed'
        m=json.loads((folder/'manifest.json').read_text())
        assert m['status']=='PROPOSED' and m['runtime_authorization']=='PREVIEW_ONLY'
        assert m['source']['candidate_count']==1 and len(m['source']['sha256'])==64
        assert len(m['states'])==6
        for name,checksum in m['files'].items():
            assert hashlib.sha256((folder/name).read_bytes()).hexdigest()==checksum, (slug,name)
    print('PASS: three PROPOSED candidates, exact derived PNG hashes and six state contracts')
if __name__=='__main__': validate()
