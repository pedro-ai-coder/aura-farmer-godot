"""Original Hero Clash button source artwork. No third-party images or font outlines.
Editable SVGs are the source of truth; Godot rasterizes them to the shipped PNGs.
"""
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]/'assets/ui-button-candidates/v1'
STATES=['normal','hover','focus','pressed','selected','disabled']
PALETTES={
 'primary':('#ffe790','#f8bd3f','#e59626','#9b541c','#fff5bd'),
 'secondary':('#fff9e6','#ddd8bf','#aab6b7','#3c5f78','#ffffff'),
 'destructive':('#ffb6a0','#ef795d','#cd4c40','#783649','#ffe4cd'),
}
def action(family,state):
 top,face,edge,base,shine=PALETTES[family]
 if state=='disabled':top,face,edge,base,shine=('#b5c0c7','#8c9da8','#697c8b','#344957','#d1d9dd')
 if state in ['hover','focus']:top=shine
 # A cast shell, recessed end shoulders and a broad satin face. The depth is authored into the image.
 y=5 if state=='pressed' else 0
 svg=f'''<svg xmlns="http://www.w3.org/2000/svg" width="512" height="96" viewBox="0 0 512 96">
 <defs><linearGradient id="face" x2="0" y2="1"><stop stop-color="{top}"/><stop offset=".38" stop-color="{face}"/><stop offset="1" stop-color="{face}"/></linearGradient>
 <linearGradient id="edge" x2="0" y2="1"><stop stop-color="{edge}"/><stop offset="1" stop-color="{base}"/></linearGradient></defs>
 <path d="M20 7 H474 Q481 7 486 12 L503 29 Q506 32 506 39 V74 Q506 80 501 84 L489 91 H20 Q13 91 9 87 L5 81 V25 Q5 19 10 14Z" fill="#13233a"/>
 <path d="M12 52 H500 V74 L486 86 H22 L12 77Z" fill="url(#edge)"/>
 <path d="M23 80 H480 L492 72 V79 L484 85 H24Z" fill="{edge}"/>
 <g transform="translate(0,{y})">
 <path d="M23 5 H474 Q480 5 484 9 L500 25 V65 Q500 69 496 72 L484 79 H24 L11 68 V22 Q11 16 16 11Z" fill="{edge}"/>
 <path d="M25 9 H473 L495 28 V62 L482 72 H27 L17 63 V24Z" fill="url(#face)"/>
 <path d="M25 9 H473 L487 21 H32 L17 33 V24Z" fill="{shine}" opacity=".75"/>
 <path d="M17 33 L32 22 V61 L27 68 L17 59Z" fill="{edge}" opacity=".52"/>
 <path d="M480 23 L495 35 V62 L482 72 L474 63Z" fill="{edge}" opacity=".66"/>
 <path d="M32 62 H474 L482 72 H27Z" fill="{edge}" opacity=".30"/>
 <path d="M34 18 H468" stroke="{shine}" stroke-width="2" stroke-linecap="round" opacity=".58"/>
 </g>'''
 if state=='focus':svg+='<path d="M22 2 H476 L509 28 V77 L489 94 H20 L2 80 V22Z" fill="none" stroke="#f7edcd" stroke-width="3"/><path d="M24 5 H475 L506 29 V76 L488 91 H21 L5 79 V24Z" fill="none" stroke="#4ea3ff" stroke-width="2"/>'
 if state=='selected':svg+='<path d="M470 20 L479 29 L493 13" fill="none" stroke="#13233a" stroke-width="4" stroke-linejoin="round"/>'
 return svg+'</svg>\n'
def selection(state):
 color={'normal':'#55778f','hover':'#70c7ff','focus':'#fff9e9','pressed':'#3e98da','selected':'#f8c45f','disabled':'#71808b'}[state]
 width=5 if state in ['selected','focus'] else 3
 svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256"><path d="M18 4 H233 L252 23 V235 L235 252 H18 L4 238 V18Z" fill="none" stroke="#13233a" stroke-width="{width+3}"/><path d="M18 4 H233 L252 23 V235 L235 252 H18 L4 238 V18Z" fill="none" stroke="{color}" stroke-width="{width}"/>'
 if state=='focus':svg+='<path d="M22 11 H230 L245 26 V231 L232 245 H22 L11 234 V22Z" fill="none" stroke="#4ea3ff" stroke-width="2"/>'
 if state=='selected':svg+='<path d="M207 2 H233 L254 23 V49 H221 L207 35Z" fill="#13233a"/><path d="M212 5 H232 L250 25 V44 H223 L212 33Z" fill="#f8c45f"/><path d="M219 24 L227 32 L242 16" fill="none" stroke="#13233a" stroke-width="5" stroke-linecap="round" stroke-linejoin="round"/>'
 return svg+'</svg>\n'
for family in [*PALETTES,'selection']:
 for state in STATES:
  (ROOT/'source'/f'{family}-{state}.svg').write_text(selection(state) if family=='selection' else action(family,state))
print('24 original editable SVG state assets')
