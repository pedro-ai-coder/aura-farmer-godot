"""Deterministic registration of creator-approved 2026-11-13 artwork.

No repainting or synthetic poses. Preserve RGB source pixels, isolate the main
alpha component, remove low-alpha matte noise, and pad without resampling.
Requires the existing Pillow/numpy/scipy artwork toolchain; not a build step.
"""
import hashlib
import json
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets/production/hero-motion-v3'
HEROES = {
    'sigma': ('sigma', 'original'), 'cool-kid': ('cool-kid', 'original'),
    'alpha-chad': ('alpha', 'original'), 'pixel-vixen': ('sigma', 'female'),
    'byte-baddie': ('cool-kid', 'female'), 'block-queen': ('alpha', 'female'),
}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def isolate(pixels):
    alpha = pixels[:, :, 3]
    # Empty backgrounds and colored matte speckles have weak alpha. Keep one
    # connected character, including its held equipment; never adjacent bodies.
    labels, _ = ndimage.label(alpha > 128, structure=np.ones((3, 3)))
    areas = np.bincount(labels.ravel()); areas[0] = 0
    component = areas.argmax()
    assert areas[component] > 1000
    keep = labels == component
    result = pixels.copy()
    result[:, :, 3] = np.where(keep, np.clip((alpha.astype(float)-128)*255/125, 0, 255), 0).astype(np.uint8)
    result[result[:, :, 3] == 0] = 0
    return Image.fromarray(result)


def main():
    manifest = {'version': 'hero-motion-v3', 'approval_date': '2026-11-13',
                'approval': 'Creator approved all remaining motion/design candidates and explicitly authorized integration in this chat.',
                'generator': 'scripts/prepare_approved_motion.py',
                'processing': 'Largest connected alpha>128 component; alpha remap (alpha-128)*255/125; unchanged RGB, no repainting, no resampling; 512px padded run cells.',
                'cell': 512, 'pivot': [256, 464], 'fps': 12, 'heroes': {}}
    for slug, (hero, appearance) in HEROES.items():
        source = OUT/'source'/slug
        folder = OUT/slug; folder.mkdir(parents=True, exist_ok=True)
        raw = np.array(Image.open(source/'run.png').convert('RGBA'))
        h, w = raw.shape[:2]
        atlas = Image.new('RGBA', (2048, 1024))
        frames = []
        heights = []
        for i in range(8):
            x0, x1 = round(i % 4*w/4), round((i % 4+1)*w/4)
            y0, y1 = round(i//4*h/2), round((i//4+1)*h/2)
            image = isolate(raw[y0:y1, x0:x1])
            bounds = image.getbbox(); assert bounds
            assert bounds[0] > 0 and bounds[2] < image.width
            # A fixed registration rectangle retains authored airborne offsets.
            # The common floor is 432 source pixels in these approved boards.
            atlas.paste(image, (i % 4*512+34, i//4*512+32))
            heights.append(bounds[3]-bounds[1])
            frames.append({'source_rect': [x0,y0,x1-x0,y1-y0], 'used_rect': list(bounds)})
        atlas.save(folder/'run.png')
        portrait = isolate(np.array(Image.open(source/'portrait.png').convert('RGBA')))
        bounds = portrait.getbbox(); assert bounds
        portrait = portrait.crop(bounds)
        padded = Image.new('RGBA', (portrait.width+32, portrait.height+32))
        padded.paste(portrait, (16,16)); padded.save(folder/'portrait.png')
        # New Pixel Vixen identity is also available to the existing HUD resolver.
        if slug == 'pixel-vixen':
            hud = padded.crop((0,0,padded.width,round(padded.height*0.53)))
            hud.save(folder/'hud.png')
        files = {p.name: digest(p) for p in folder.glob('*.png')}
        manifest['heroes'][slug] = {'hero_id': hero, 'appearance': appearance,
            'source': {name: digest(source/name) for name in ['run.png','portrait.png']},
            'files': files, 'frames': frames, 'body_height': float(np.median(heights)),
            'idle_height': portrait.height, 'portrait_dimensions': list(padded.size)}
    (OUT/'manifest.json').write_text(json.dumps(manifest, indent=2)+'\n')
    print('PASS: six approved identities, 48 isolated native-resolution poses, portraits and provenance')


if __name__ == '__main__':
    main()
