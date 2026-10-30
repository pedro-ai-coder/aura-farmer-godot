"""Encode real capture timestamps; do not replace stalls with constant FPS."""
import argparse
import json
from pathlib import Path
import subprocess
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('folder',type=Path)
parser.add_argument('output',type=Path)
args=parser.parse_args()
folder=args.folder.resolve()
frames=json.loads((folder/'recording.json').read_text())['frames']
lines=['ffconcat version 1.0']
for i,row in enumerate(frames):
    path=(folder/row['file']).as_posix()
    if "'" in path:raise ValueError('Unsupported apostrophe in capture path')
    lines.append("file '"+path+"'")
    duration=frames[i+1]['seconds']-row['seconds'] if i+1<len(frames) else 1/60
    lines.append(f'duration {duration:.6f}')
lines.append("file '"+(folder/frames[-1]['file']).as_posix()+"'")
manifest=folder/'frames.ffconcat';manifest.write_text('\n'.join(lines)+'\n')
subprocess.run(['ffmpeg','-y','-loglevel','error','-safe','0','-i',str(manifest),'-vf','pad=ceil(iw/2)*2:ceil(ih/2)*2','-fps_mode','vfr','-c:v','libx264','-crf','22','-pix_fmt','yuv420p','-video_track_timescale','1000000','-movflags','+faststart',str(args.output.resolve())],check=True)
print('Encoded',len(frames),'actual native frames with their capture intervals')
