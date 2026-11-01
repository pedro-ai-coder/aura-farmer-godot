"""Reproduce candidate frame-registration JSON; this tool NEVER edits PNGs.

Development-only dependencies: Pillow, NumPy. Default mode checks committed
geometry. --write is restricted to preview candidates and preserves source pins.
The touching Block Queen defeat poses require the documented x=512 split.
"""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image
import numpy as np


def build_geometry(atlas: Path, slug: str):
    img=Image.open(atlas);alpha=np.array(img.getchannel('A'));solid=alpha>96;seen=np.zeros(solid.shape,dtype=bool);h,w=solid.shape;components=[]
    for yy,xx in zip(*np.where(solid)):
        if seen[yy,xx]:continue
        stack=[(int(yy),int(xx))];seen[yy,xx]=True;pts=[]
        while stack:
            y,x=stack.pop();pts.append((y,x))
            for dy,dx in [(-1,0),(1,0),(0,-1),(0,1)]:
                ny,nx=y+dy,x+dx
                if 0<=ny<h and 0<=nx<w and solid[ny,nx] and not seen[ny,nx]:seen[ny,nx]=True;stack.append((ny,nx))
        if len(pts)>=4:
            a=np.array(pts,dtype=np.int32);components.append(a)
    def bbox(a):
        return [int(a[:,1].min()),int(a[:,0].min()),int(a[:,1].max()+1),int(a[:,0].max()+1)]
    large=[];small=[]
    for a in components:
        if len(a)<5000:small.append(a);continue
        b=bbox(a)
        if slug=='block-queen' and b[1]>1280 and b[2]-b[0]>400:
            large.extend([a[a[:,1]<512],a[a[:,1]>=512]])
        else:large.append(a)
    large.sort(key=lambda a:(int((bbox(a)[1]+bbox(a)[3])/2)//256,bbox(a)[0]));assert len(large)==24
    groups=[list([a]) for a in large];boxes=[bbox(a) for a in large]
    for a in small:
        b=bbox(a);cx=(b[0]+b[2])/2;cy=(b[1]+b[3])/2
        def dist(q):
            dx=max(q[0]-cx,0,cx-q[2]);dy=max(q[1]-cy,0,cy-q[3]);return dx*dx+dy*dy+0.001*((cx-(q[0]+q[2])/2)**2+(cy-(q[1]+q[3])/2)**2)
        nearest=min(range(24),key=lambda i:dist(boxes[i]));groups[nearest].append(a)
    owners=np.full(solid.shape,-1,dtype=np.int16)
    for i,group in enumerate(groups):
        for a in group:owners[a[:,0],a[:,1]]=i
    base_height=float(np.median([boxes[i][3]-boxes[i][1] for i in range(4)]));frames=[]
    for i in range(24):
        mask=owners==i
        for repeat in range(2):
            d=mask.copy();d[1:]|=mask[:-1];d[:-1]|=mask[1:];d[:,1:]|=mask[:,:-1];d[:,:-1]|=mask[:,1:];mask=d
        mask &= (alpha>0)&((owners<0)|(owners==i))
        ys,xs=np.where(mask);l=int(xs.min());r=int(xs.max()+1);t=int(ys.min());b=int(ys.max()+1);m=mask[t:b,l:r]
        open_rects={};rects=[]
        for y,row in enumerate(m):
            edge=np.diff(np.r_[False,row,False].astype(np.int8));runs=list(zip(np.where(edge==1)[0].tolist(),np.where(edge==-1)[0].tolist()));keys={(a,z-a) for a,z in runs}
            for key in list(open_rects):
                if key not in keys:rects.append(open_rects.pop(key))
            for x,width in keys:
                if (x,width) in open_rects:open_rects[x,width][3]+=1
                else:open_rects[x,width]=[x,y,width,1]
        rects+=list(open_rects.values());rects.sort(key=lambda q:(q[1],q[0]))
        pivot=[round((i%4)*256+128-l,4),round(boxes[i][3]-base_height*.1-t,4)]
        frames.append({'source_rect':[l,t,r-l,b-t],'pivot':pivot,'mask_rects':rects})
    return frames, 64.0/base_height


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[1])
    parser.add_argument("--write",action="store_true")
    args=parser.parse_args()
    for slug in ["byte-baddie","block-queen"]:
        folder=args.root/"assets/art-candidates"/slug/"v2"
        manifest=json.loads((folder/"manifest.json").read_text())
        if manifest["status"]!="UNAPPROVED_CREATOR_REVIEW_CANDIDATE" or manifest["runtime_authorization"]!="PREVIEW_ONLY":
            raise ValueError("Refusing to rewrite approved/production art metadata")
        atlas=folder/manifest["atlas"]
        if hashlib.sha256(atlas.read_bytes()).hexdigest()!=manifest["atlas_sha256"]:
            raise ValueError("Source PNG must match its existing pin before registration")
        frames,scale=build_geometry(atlas,slug)
        data=("[\n"+",\n".join(json.dumps(f,separators=(",",":")) for f in frames)+"\n]\n").encode()
        checksum=hashlib.sha256(data).hexdigest()
        if args.write:
            (folder/"frames.json").write_bytes(data)
            manifest["frame_geometry_sha256"]=checksum;manifest["world_scale"]=scale
            (folder/"manifest.json").write_text(json.dumps(manifest,indent=2)+"\n")
        elif ((folder/"frames.json").read_bytes()!=data or manifest["frame_geometry_sha256"]!=checksum
                or abs(float(manifest["world_scale"])-scale)>1e-12):
            raise ValueError("Committed source registration differs: "+slug)
        print("PASS: reproducible source registration without PNG modification: "+slug)


if __name__=="__main__":main()
