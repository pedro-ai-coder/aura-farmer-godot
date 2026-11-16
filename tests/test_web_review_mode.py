"""Deployment regression: repository vercel.json can override API build settings.
Select the candidate from the actual Preview branch context, never production.
"""
from pathlib import Path
import os,subprocess,unittest
HELPER=Path(__file__).resolve().parents[1]/'scripts/web_review_mode.sh'
BRANCH='review/neon-cool-kid-articulated-preview'
class WebReviewModeTests(unittest.TestCase):
    def mode(self,target=None,branch=BRANCH,flag=None):
        env=os.environ.copy()
        for key in ('VERCEL_ENV','VERCEL_GIT_COMMIT_REF','COOL_KID_RIG_REVIEW'):env.pop(key,None)
        if target is not None:env['VERCEL_ENV']=target
        env['VERCEL_GIT_COMMIT_REF']=branch
        if flag is not None:env['COOL_KID_RIG_REVIEW']=flag
        return subprocess.run(['bash','-c','source "$1"; configure_web_review_mode || exit $?; printf "%s" "${COOL_KID_RIG_REVIEW:-0}"','sh',str(HELPER)],env=env,text=True,capture_output=True)
    def test_local_stays_normal(self):self.assertEqual(self.mode().stdout,'0')
    def test_preview_branch_opts_into_candidate(self):self.assertEqual(self.mode('preview').stdout,'1')
    def test_staging_api_alias_opts_into_candidate(self):self.assertEqual(self.mode('staging').stdout,'1')
    def test_other_preview_stays_normal(self):self.assertEqual(self.mode('preview','feat/other').stdout,'0')
    def test_production_stays_normal(self):self.assertEqual(self.mode('production').stdout,'0')
    def test_production_explicit_candidate_is_rejected(self):self.assertEqual(self.mode('production',flag='1').returncode,2)
    def test_explicit_local_review_still_supported(self):self.assertEqual(self.mode(flag='1').stdout,'1')
if __name__=='__main__':unittest.main()
