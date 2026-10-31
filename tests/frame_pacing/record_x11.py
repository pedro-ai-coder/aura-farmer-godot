"""Record actual native frame presentation through X11, outside benchmark runs.

Run under an existing X11 display or xvfb-run. Movie sampling is 30fps, not a
rendering-FPS measurement. The game uses real elapsed time and routed touch.
"""
import argparse
import os
from pathlib import Path
import signal
import subprocess
import time
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('output',type=Path)
parser.add_argument('--project',type=Path,default=Path(__file__).resolve().parents[2])
parser.add_argument('--godot',default='godot')
parser.add_argument('--scenario',choices=['movement','dense'],default='movement')
args=parser.parse_args();folder=args.output.resolve();folder.mkdir(parents=True,exist_ok=True)
for name in ['ready','capturing']:(folder/name).unlink(missing_ok=True)
with (folder/'godot.log').open('w') as game_log,(folder/'ffmpeg.log').open('w') as video_log:
    game=subprocess.Popen([args.godot,'--path',str(args.project),'--audio-driver','Dummy','--rendering-driver','opengl3','--resolution','844x390','--position','0,0','--script','res://tests/frame_pacing/record.gd','--',str(folder),args.scenario,'--screen-capture'],stdout=game_log,stderr=subprocess.STDOUT)
    capture=None
    try:
        deadline=time.monotonic()+30
        while not (folder/'ready').exists():
            if game.poll() is not None or time.monotonic()>deadline:raise RuntimeError('Godot capture did not initialize')
            time.sleep(0.02)
        capture=subprocess.Popen(['ffmpeg','-y','-loglevel','error','-f','x11grab','-framerate','30','-video_size','844x390','-i',os.environ['DISPLAY']+'+0,0','-c:v','libx264','-preset','ultrafast','-threads','1','-crf','22','-pix_fmt','yuv420p','-movflags','+faststart',str(folder/'video.mp4')],stdout=video_log,stderr=subprocess.STDOUT)
        time.sleep(0.1)
        if capture.poll() is not None:raise RuntimeError('X11 recorder failed')
        (folder/'capturing').touch()
        if game.wait(timeout=30):raise RuntimeError('Godot recording failed')
    finally:
        if game.poll() is None:game.terminate();game.wait(timeout=5)
        if capture is not None and capture.poll() is None:capture.send_signal(signal.SIGINT);capture.wait(timeout=10)
if not (folder/'video.mp4').stat().st_size:raise RuntimeError('Empty video')
print('Captured native X11 presentation; movie sample rate is not engine FPS')
