#!/usr/bin/env python3
"""Original Hero Clash HUD vector components; no copied mockup pixels/artwork.
Run from any directory. Runtime SVGs are the editable sources. No external fonts.
"""
from pathlib import Path
import hashlib, json
ROOT=Path(__file__).resolve().parents[1]
INK='#0b2034'; BLUE='#0869b0'; GOLD='#ffca28'; PAPER='#fff5dc'
DEFS='''<defs>
<linearGradient id="paper" x2="0.1" y2="1"><stop stop-color="#fffaf0"/><stop offset="1" stop-color="#e8dfc5"/></linearGradient>
<linearGradient id="gold" x2="0.12" y2="1"><stop stop-color="#ffe467"/><stop offset="0.45" stop-color="#ffce21"/><stop offset="1" stop-color="#e9a60b"/></linearGradient>
<linearGradient id="blue" x2="0.2" y2="1"><stop stop-color="#168fe4"/><stop offset="1" stop-color="#074d89"/></linearGradient>
<linearGradient id="navy" x2="0.3" y2="1"><stop stop-color="#153c5c"/><stop offset="1" stop-color="#071c30"/></linearGradient>
<radialGradient id="dial" cx="0.3" cy="0.15" r="0.9"><stop stop-color="#144d78"/><stop offset="0.58" stop-color="#0b2a45"/><stop offset="1" stop-color="#041529"/></radialGradient>
<pattern id="dots" width="6" height="6" patternUnits="userSpaceOnUse"><circle cx="1" cy="1" r="0.85" fill="#0b2034" opacity="0.19"/></pattern>
</defs>'''
assets=[]
def svg(name,w,h,body,component,supersedes=None):
 text=f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}">\n{DEFS}\n{body}\n</svg>\n'
 p=ROOT/(name+'.svg');p.write_text(text)
 assets.append({'id':'hud-v2/'+name,'source_path':str(p.relative_to(ROOT.parents[2])),'runtime_path':'res://assets/ui-hud-candidates/v2/'+name+'.svg','component':component,'dimensions':[w,h],'transparency':'RGBA; outside silhouette and authored apertures','editable_source':str(p.relative_to(ROOT.parents[2])),'sha256':hashlib.sha256(text.encode()).hexdigest(),'approval_status':'CANDIDATE_PENDING_EXACT_BYTE_CREATOR_APPROVAL','supersedes_visual_usage_only':supersedes})
svg('player-frame',620,170,f'''
<path d="M4 143 57 4 184 4 197 18 559 18 570 31 616 31 583 165 14 165Z" fill="{INK}"/>
<path d="M10 142 62 10 180 10 193 24 556 24 566 37 608 37 578 158 18 158Z" fill="url(#gold)"/>
<path d="M16 138 66 16 176 16 190 30 553 30 562 43 600 43 572 151 21 151Z" fill="url(#blue)"/>
<path d="M181 31 548 31 558 44 596 44 569 145 156 145Z" fill="url(#paper)"/>
<path d="M195 34 537 34 541 39 194 39Z" fill="#fffdf3"/>
<path d="M185 147 568 147 564 152 182 152Z" fill="#7892a0"/>
<path d="M74 21 172 21 189 43 159 141 25 141Z" fill="url(#blue)" stroke="{INK}" stroke-width="5"/>
<path d="M80 27 166 27 181 45 154 135 33 135Z" fill="url(#dots)"/>
<path d="M177 28 188 28 199 44 170 138 160 138 188 45Z" fill="{PAPER}"/>
<path d="M200 77 575 77 563 113 190 113Z" fill="{INK}"/>
<path d="M192 121 559 121 551 145 184 145Z" fill="{INK}"/>
<path d="M531 32 544 32 552 44 579 44 575 49 547 49Z" fill="{INK}"/>
<path d="M515 34 524 34 532 45 523 45Z" fill="url(#dots)"/>
<path d="M15 154 154 154 151 158 17 158Z" fill="#fff2a9"/>
''','Player status / portrait window','support/hp')
svg('hp-fill',384,38,'''<path d="M12 2H382L370 36H2Z" fill="#c51f37"/><path d="M14 3H380L370 30H4Z" fill="#ff343d"/><path d="M15 4H375L373 8H13Z" fill="#ff7e69" opacity="0.75"/>''','Live red HP meter')
svg('shield-fill',384,28,'''<path d="M9 1H383L374 27H1Z" fill="#03436e"/><path d="M10 2H380L374 23H3Z" fill="url(#blue)"/><path d="M11 3H377L376 5H10Z" fill="#5bc5ff" opacity="0.65"/>''','Live Shield meter')
svg('shield-mark',28,30,'''<path d="M14 2 25 6 24 17Q22 24 14 28 6 24 4 17L3 6Z" fill="#fff9e9"/>''','Independent Shield semantic icon')
svg('wave-frame',448,86,f'''
<path d="M26 3H445L416 83H0Z" fill="{INK}"/>
<path d="M39 8H427L403 75H14Z" fill="url(#gold)"/>
<path d="M58 10H417L397 68H38Z" fill="#ffcd21"/>
<path d="M41 8H49L25 75H17Z M428 8H437L413 75H404Z" fill="{BLUE}"/>
<path d="M64 12H411L409 16H63Z" fill="#ffe888"/>
<path d="M387 42H405L395 68H369Z" fill="url(#dots)"/>
<path d="M43 75H399L396 78H42Z" fill="#ac7614"/>
''','Angular Wave / encounter banner','support/wave')
for state in ['normal','hover','focus','pressed','disabled']:
 face='#fff9e9' if state=='hover' else '#ddd8c8' if state=='pressed' else 'url(#paper)'
 edge='#fff5dc' if state=='focus' else '#61bcff' if state=='hover' else GOLD
 y=3 if state=='pressed' else 0
 svg('pause-'+state,112,106,f'''
<g transform="translate(0 {y})"><path d="M25 2H87L109 24V79L87 101H23L3 81V25Z" fill="{INK}"/>
<path d="M26 7H85L103 25V77L85 95H26L9 78V27Z" fill="{edge}"/>
<path d="M29 12H82L97 28V74L82 89H29L15 75V30Z" fill="url(#blue)"/>
<path d="M32 15H81L94 29V71L80 86H31L18 72V32Z" fill="{face}" stroke="{INK}" stroke-width="4"/>
<path d="M35 20H78L85 28H28Z" fill="#fffdf5" opacity="0.65"/>
<path d="M40 34H51V68H40Z M61 34H72V68H61Z" fill="{INK}"/>
</g>''','Actual Pause Button / '+state,'menu/secondary')
svg('xp-frame',430,78,f'''
<path d="M27 2H317L335 20H383L429 75H0Z" fill="{INK}"/>
<path d="M31 7H315L332 25H380L418 69H10Z" fill="url(#gold)"/>
<path d="M35 10H308L325 27H375L408 65H17Z" fill="url(#paper)"/>
<path d="M317 7H327L344 20H383L390 28H337Z" fill="url(#blue)"/>
<path d="M56 43H379L395 62H42Z" fill="{INK}"/>
<path d="M57 46H377L388 59H48Z" fill="#073052"/>
<path d="M298 12H307L318 25H289Z" fill="url(#dots)"/>
''','Grouped Level / XP','support/xp')
svg('equipment-strip',900,126,f'''
<path d="M8 4H880L897 23V94L878 123H23L2 103V18Z" fill="{INK}"/>
<path d="M14 8H875L891 26V92L874 117H25L9 100V20Z" fill="url(#navy)"/>
<path d="M22 97H879L867 116H30Z" fill="#071d31"/>
<path d="M14 8H875L880 13H19Z" fill="#3a6684"/>
<path d="M15 88H20V103L32 116H24L9 101V88Z M872 99H884L871 119H859Z" fill="url(#gold)"/>
<path d="M339 16H342V116H339Z" fill="#427b9e"/>
''','Single eight-slot weapon / passive support frame','equipment/weapon-filled, equipment/passive-filled')
svg('equipment-portrait',520,208,f'''
<path d="M15 3H502L517 19V183L500 205H20L3 187V19Z" fill="{INK}"/>
<path d="M20 8H497L511 23V181L496 199H24L9 184V23Z" fill="url(#navy)"/>
<path d="M17 13H498L501 17H20Z" fill="#3a6684"/>
<path d="M21 99H499V102H21Z" fill="#2b5876"/>
<path d="M10 178H15V187L25 199H18L5 185Z M494 186H508L497 202H484Z" fill="url(#gold)"/>
''','Portrait 3 + 5 equipment fallback')
for state in ['empty','equipped','focus']:
 border='#d1d9da' if state=='empty' else '#ffce3e' if state=='equipped' else '#7edcff'
 center='''<circle cx="48" cy="45" r="17" fill="none" stroke="#98b0b8" stroke-width="4"/><path d="M37 43H59V47H37Z" fill="#98b0b8"/>''' if state=='empty' else ''
 svg('slot-'+state,96,96,f'''
<path d="M9 2H85L94 11V84L84 94H10L2 85V11Z" fill="{INK}"/>
<path d="M10 6H83L89 12V82L82 89H12L7 83V13Z" fill="{border}"/>
<path d="M13 10H81L86 15V79L79 86H15L11 80V17Z" fill="url(#paper)"/>
<path d="M16 13H78L82 17V75H16Z" fill="#faf6e9" opacity="0.6"/>
<path d="M11 79H85L78 87H16Z" fill="#9caab2" opacity="0.5"/>
<path d="M68 13H80L83 16V34Z" fill="url(#dots)"/>{center}
''','Equipment slot / '+state)
svg('level-tab',78,24,f'<path d="M5 1H76V18L70 23H2V7Z" fill="{INK}"/><path d="M8 2H73V4H6Z" fill="#47728d"/>','Equipment level badge')
svg('flex-body',320,320,f'''
<circle cx="160" cy="163" r="151" fill="#04101f"/>
<circle cx="160" cy="157" r="149" fill="url(#navy)" stroke="{INK}" stroke-width="7"/>
<circle cx="160" cy="157" r="139" fill="url(#blue)" stroke="#2b83c2" stroke-width="3"/>
<circle cx="160" cy="157" r="128" fill="url(#dial)" stroke="#03192d" stroke-width="6"/>
<circle cx="160" cy="157" r="120" fill="none" stroke="#226da3" stroke-width="2"/>
<path d="M75 63A125 125 0 0 1 244 65" fill="none" stroke="#75c3f3" stroke-width="3" opacity="0.35"/>
<path d="M59 248A136 136 0 0 0 267 239" fill="none" stroke="#021629" stroke-width="5"/>
''','Static circular Flex material; dynamic Aura/READY remains runtime','flex/*')
svg('ability-nameplate',360,54,f'''
<path d="M24 2H345L358 15V40L344 51H4L1 40Z" fill="{INK}"/>
<path d="M27 6H343L353 16V38L342 46H8L6 38Z" fill="url(#gold)"/>
<path d="M37 8H339L349 17V36L339 42H20L16 36Z" fill="url(#navy)"/>
<path d="M39 10H338L341 13H37Z" fill="#48728d"/>
''','Separate hero-specific ability nameplate')
svg('boss-frame',520,64,f'<path d="M20 2H518L501 62H2Z" fill="{INK}"/><path d="M24 7H508L495 55H12Z" fill="url(#paper)"/><path d="M25 8H493L491 12H23Z" fill="#fffdf3"/><path d="M30 43H482L479 51H27Z" fill="#102e45"/>','Boss health / reserved encounter region')
(ROOT/'manifest.json').write_text(json.dumps({'version':2,'status':'CANDIDATE_PENDING_CREATOR_REVIEW','direction':'Creator-selected first Gameplay HUD V2 composition, 2026-10-29','provenance':'Original geometric SVG artwork authored in this repository; no extracted mockup pixels, new characters, fonts or icons.','generator':'assets/ui-hud-candidates/v2/source/build_assets.py','portrait_shader':{'path':'assets/ui-hud-candidates/v2/portrait_crop.gdshader','sha256':hashlib.sha256((ROOT/'portrait_crop.gdshader').read_bytes()).hexdigest(),'approval_status':'CANDIDATE_PENDING_EXACT_BYTE_CREATOR_APPROVAL'},'resources':assets},indent=2)+'\n')
print(f'Wrote {len(assets)} original editable SVGs')
