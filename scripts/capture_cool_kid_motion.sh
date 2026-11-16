#!/usr/bin/env bash
# Offline native frames at canonical playback rate. Not a real-time FPS test.
set -euo pipefail
cd "$(dirname "$0")/.."
: "${GODOT_BIN:=godot}"
: "${DISPLAY:=:99}"
[[ "$("$GODOT_BIN" --version)" =~ ^4\.7\.2\.stable(\.|$) ]] || { echo 'Official Godot 4.7.2 required' >&2; exit 2; }
mkdir -p build
touch build/.gdignore
kind="${1:-ab}"
output="${2:-build/cool-kid-v2}"
mkdir -p "$output/evidence/$kind"
output="$(realpath "$output")"
script='res://tests/cool_kid_rig/record_gameplay.gd'
args=(--ab)
case "$kind" in
    ab) ;;
    flex) args=(--full --start=90) ;;
    defeat) args=(--defeat --start=90) ;;
    inspection) script='res://tests/cool_kid_rig/inspect_motion.gd';args=() ;;
    *) echo 'Use ab, flex, defeat or inspection' >&2;exit 2 ;;
esac
ffmpeg -v error -f rawvideo -pixel_format rgba -video_size 1280x720 -framerate 30 \
    -i 'tcp://127.0.0.1:9876?listen=1' -c:v libx264 -threads 2 -preset fast -crf 20 \
    -pix_fmt yuv420p -movflags +faststart -y "$output/$kind.mp4" \
    > "$output/evidence/$kind/encoder.log" 2>&1 &
encoder_pid=$!
trap 'kill "$encoder_pid" 2>/dev/null || true' EXIT
DISPLAY="$DISPLAY" "$GODOT_BIN" --audio-driver Dummy --path . --script "$script" \
    -- "$output/evidence/$kind" "${args[@]}" --raw \
    > "$output/evidence/$kind/godot.log" 2>&1
wait "$encoder_pid"
trap - EXIT
if rg -n 'SCRIPT ERROR:|Parse Error:|(^|[[:space:]])ERROR:' "$output/evidence/$kind/godot.log"; then exit 1;fi
ffprobe -v error -show_entries format=duration:stream=width,height,avg_frame_rate,nb_frames \
    -of json "$output/$kind.mp4" > "$output/evidence/$kind/video.json"
