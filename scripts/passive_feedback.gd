extends RefCounted
## Read-only presentation adapter. All deadlines/counters come from the run.
## No gameplay timer, RNG, save data, damage or independent buff simulation.
const Offers=preload("res://scripts/solo_offer_rules.gd")
const Rules=preload("res://scripts/solo_passive_rules.gd")
const COVERAGE={
    "main-character":"stat", "terminally-online":"stat", "built-different":"stat",
    "thick-skin":"stat", "caught-4k":"stat", "big-meme":"stat", "timeline":"stat",
    "hands-on-sight":"conditional", "cope-harder":"support", "certified-w":"support",
    "no-cap-streak":"trigger", "w-wifi":"timed", "let-him-cook":"stack",
    "homie-check":"healing", "big-chad":"shield", "its-over":"conditional",
    "aura-viral":"timed", "so-back":"healing", "six-to-seven":"stack",
    "absolute-cinema":"legendary", "w-squad":"legendary",
    "too-sigma":"legendary", "no-u":"legendary"
}
const MAX_PENDING=6
const MAX_RINGS=4
var pending: Array[Dictionary]=[]
var current: Dictionary={}
var current_until: float=0.0
var statuses: Dictionary={}
var rings: Array[Dictionary]=[]
var last_notice: Dictionary={}
var last_poll: float=-INF
var next_expiry: float=INF
var observed_time: float=-1.0
var observed_run: String=""
var revision: int=0
var committed: int=0

func reset() -> void:
    pending.clear();current.clear();statuses.clear();rings.clear();last_notice.clear()
    current_until=0;last_poll=-INF;next_expiry=INF;observed_time=-1;observed_run="";committed=0;revision+=1

static func name_for(id: String) -> String:
    return str(Offers.PASSIVE_DATA.get(id,{}).get("name",id))

static func number(value: float) -> String:
    return "%.0f" % value if is_equal_approx(value,roundf(value)) else "%.1f" % value

func notify(game, id: String, title: String, detail: String, kind: String="proc", value: float=0.0) -> void:
    if game.mode in ["menu","heroes","won","lost"]:return
    last_poll=-INF
    # Actual repeated healing/absorption is coalesced, never a message per hit.
    var key: String=kind+":"+id
    var now: float=game.run_time
    if kind in ["healing","absorption"]:
        if current.get("key","")==key and now<current_until:
            current["value"]=float(current.get("value",0))+value
            current["detail"]=("+%s HP restored" if kind=="healing" else "%s damage absorbed") % number(current.value)
            revision+=1;return
        for entry in pending:
            if entry.get("key","")==key:
                entry["value"]=float(entry.get("value",0))+value
                entry["detail"]=("+%s HP restored" if kind=="healing" else "%s damage absorbed") % number(entry.value)
                revision+=1;return
    elif kind=="proc":
        # Progress cues represent the latest real threshold, not a stale 1/5
        # message while the slot already shows 5/5. Never extend its lifetime.
        if current.get("key","")==key and now<current_until:
            current["detail"]=detail;revision+=1;return
        for queued in pending:
            if queued.get("key","")==key:
                queued["detail"]=detail;revision+=1;return
        if now-float(last_notice.get(key,-INF))<1.2:return
    last_notice[key]=now
    var entry: Dictionary={"id":id,"title":title,"detail":detail,"kind":kind,"key":key,"value":value}
    if pending.size()>=MAX_PENDING:
        # Keep confirmed changes; discard an older combat notice first.
        var remove:=0
        for i in range(pending.size()):
            if pending[i].kind not in ["upgrade","legendary"]:remove=i;break
        pending.remove_at(remove)
    if kind in ["upgrade","legendary"]:
        var at:=0
        while at<pending.size() and pending[at].kind in ["upgrade","legendary"]:at+=1
        pending.insert(at,entry)
    else:pending.append(entry)
    revision+=1

func shield_granted(game, source: String, amount: float, duration: float) -> void:
    if amount<=0 or source not in ["big-chad","so-back","too-sigma"]:return
    notify(game,source,name_for(source),"%s shield · %.0fs" % [number(amount),duration],"shield")

func healed(game, source: String, effective: float) -> void:
    if effective>0 and source in ["homie-check","so-back"]:
        notify(game,source,name_for(source),"+%s HP restored" % number(effective),"healing",effective)

func absorbed(game, amount: float) -> void:
    if amount>0:notify(game,"","SHIELD","%s damage absorbed" % number(amount),"absorption",amount)

func primary(game, target: Vector2, old_cook: int, old_six: int) -> void:
    if game.mode!="playing":return
    last_poll=-INF
    if game.cook_stacks!=old_cook and game.cook_stacks in [1,3,5] and game._passive_level("let-him-cook")>0:
        notify(game,"let-him-cook",name_for("let-him-cook"),"%d / 5 stacks · +%s%% weapon damage" % [game.cook_stacks,number(game.cook_stacks*(2+game._passive_level("let-him-cook")))])
    var count: int=int(game.passive_timers.get("six_counter",0))
    if game._passive_level("six-to-seven")>0 and old_six==6 and count==0:
        notify(game,"six-to-seven","SIX → SEVEN","Seventh hit · burst activated")
        ring(game,target,90.0,"six-to-seven")

func flex_started(game) -> void:
    for id in ["aura-viral","absolute-cinema","w-squad"]:
        if game._passive_level(id)>0:
            var detail: String="+%s%% frequency · 5s" % number(12+6*(game._passive_level(id)-1)) if id=="aura-viral" else "+20% additive weapon damage · during Flex" if id=="absolute-cinema" else "+10% weapon damage · 6s"
            notify(game,id,name_for(id),detail)

func ring(game, center: Vector2, radius: float, id: String) -> void:
    if game.mode!="playing":return
    if rings.size()>=MAX_RINGS:rings.pop_front()
    rings.append({"center":center,"radius":radius,"until":game.run_time+0.28,"id":id})

func committed_card(game, card: Dictionary, before: Dictionary, replaced: String) -> void:
    var kind: String=str(card.get("type",""))
    if kind=="heal":
        var healed_hp: float=maxf(0,game.hp-float(before.hp))
        notify(game,"","RECOVERY CONFIRMED","+%s HP restored" % number(healed_hp) if healed_hp>0 else "HP already full · no healing applied","upgrade")
    else:
        var id: String=str(card.get("id",""))
        var weapon: bool=game.WEAPONS.has(id)
        var inventory: Array=game.weapons if weapon else game.passives
        var actual: Dictionary={}
        for item: Dictionary in inventory:
            if item.id==id:actual=item;break
        if actual.is_empty():return
        var title: String=str(game.WEAPONS[id].name) if weapon else name_for(id)
        var action: String="REPLACED" if not replaced.is_empty() else "PROMOTED" if kind.begins_with("promote") else "LEVEL UP" if kind.begins_with("upgrade") else "ACQUIRED"
        var detail: String="%s · %s · LV %d" % [action,str(actual.rarity).to_upper(),int(actual.level)]
        if not replaced.is_empty():
            var old_name: String=str(game.WEAPONS[replaced].name) if game.WEAPONS.has(replaced) else name_for(replaced)
            detail="Replaces %s · LV %d" % [old_name,int(actual.level)]
        # Describe the actual committed level, including promotion level caps.
        # Rarity alone never claims an increase in a passive's numeric value.
        var added_hp: float=maxf(0,game.max_hp-float(before.max_hp))
        if added_hp>0:detail+=" · +%s max HP" % number(added_hp)
        elif not weapon and COVERAGE.get(id,"") in ["stat","conditional","support"] and replaced.is_empty():
            detail+="\n"+brief(id,int(actual.level))
        elif not weapon and actual.rarity=="legendary" and replaced.is_empty():detail+="\n"+brief(id,int(actual.level))
        notify(game,id,title,detail,"legendary" if actual.rarity=="legendary" else "upgrade")
    committed+=1

func synchronize(game) -> void:
    if game.mode in ["menu","heroes","won","lost"]:
        if not current.is_empty() or not pending.is_empty() or not statuses.is_empty() or not rings.is_empty():reset()
        return
    if game.mode!="playing":return
    if observed_time>game.run_time or (not observed_run.is_empty() and observed_run!=game.run_id):reset()
    observed_run=game.run_id;observed_time=game.run_time
    for i in range(rings.size()-1,-1,-1):
        if game.run_time>=float(rings[i].until):rings.remove_at(i)
    if not current.is_empty() and game.run_time>=current_until:
        current.clear();revision+=1
    if current.is_empty() and not pending.is_empty():
        current=pending.pop_front();current["started"]=game.run_time
        current_until=game.run_time+(3.0 if current.kind=="legendary" else 2.0 if current.kind=="upgrade" else 1.35)
        revision+=1
    if game.run_time-last_poll<0.10 and game.run_time<next_expiry:return
    last_poll=game.run_time
    next_expiry=INF
    # Wake exactly at authoritative expiry, even between the 10 Hz UI samples.
    for deadline: float in [game.cook_expires,game.run_time+game.flex_time if game.flex_time>0 else 0.0,float(game.passive_timers.get("wifi_until",0)),float(game.passive_timers.get("viral_until",0)),float(game.passive_timers.get("w_squad_until",0)),float(game.passive_timers.get("six_ready",0)),float(game.passive_timers.get("homie_ready",0))]:
        if deadline>game.run_time:next_expiry=minf(next_expiry,deadline)
    for source: String in game.weapon_shields:
        var deadline: float=game.weapon_shields[source].until
        if deadline>game.run_time:next_expiry=minf(next_expiry,deadline)
    var next: Dictionary={}
    for item: Dictionary in game.passives:
        var id: String=item.id
        var value: Dictionary=slot_state(game,id)
        if not value.is_empty():next[id]=value
    for id: String in statuses:
        if game._passive_level(id)>0 and not next.has(id) and id in ["w-wifi","aura-viral","absolute-cinema","w-squad","let-him-cook"]:
            notify(game,id,name_for(id),"Stacks expired" if id=="let-him-cook" else "Zone ended" if id=="w-wifi" else "Bonus ended")
    if next!=statuses:statuses=next;revision+=1

static func state(short_text: String, detail: String, fraction: float, tint: String="6ff3df") -> Dictionary:
    return {"short":short_text,"detail":detail,"fraction":clampf(fraction,0,1),"color":Color(tint)}

static func slot_state(game, id: String) -> Dictionary:
    var t: Dictionary=game.passive_timers
    var now: float=game.run_time
    var lv: int=game._passive_level(id)
    if lv<=0:return {}
    if id=="let-him-cook" and now<game.cook_expires and game.cook_stacks>0:
        return state("%d/5" % game.cook_stacks,"%d / 5 stacks · %.1fs remaining" % [game.cook_stacks,game.cook_expires-now],(game.cook_expires-now)/3.0,"ffce30")
    if id=="six-to-seven":
        var count: int=int(t.get("six_counter",0))
        var recovery: float=maxf(0,float(t.get("six_ready",0))-now)
        return state("%.1fs" % recovery if recovery>0 else "%d/7" % count,"Burst recovery" if recovery>0 else "Next primary hit bursts" if count==6 else "Primary hits: %d / 7" % count,recovery/2.0 if recovery>0 else count/7.0,"ffce30" if count==6 else "c9afff")
    if id=="homie-check":
        var remaining: float=maxf(0,float(t.get("homie_ready",0))-now)
        var count: int=int(t.get("homie_count",0))
        return state("%.0fs" % ceilf(remaining) if remaining>0 else "%d/8" % count,"Healing recovery · %.1fs" % remaining if remaining>0 else "%d / 8 primary hits" % count,remaining/6.0 if remaining>0 else count/8.0)
    if id=="no-cap-streak":return state("%d/5" % (game.directional_hits%5),"Directional activations · every fifth gains pierce and damage",(game.directional_hits%5)/5.0,"80d5ff")
    if id in ["big-chad","so-back","too-sigma"] and game.weapon_shields.has(id):
        var entry: Dictionary=game.weapon_shields[id]
        var left: float=float(entry.until)-now
        if left>0 and float(entry.remaining)>0:
            return state("%.0fs" % ceilf(left),"%s shield remaining · %.1fs" % [number(entry.remaining),left],left/(5.0 if id=="too-sigma" else 4.0 if id=="big-chad" else 3.0),"80d5ff")
    if id=="so-back" and int(t.get("so_back_remaining",0))>0:
        var ticks: int=int(t.so_back_remaining)
        return state("%d/5" % ticks,"%d healing ticks remaining" % ticks,ticks/5.0)
    var until: float=float(t.get({"w-wifi":"wifi_until","aura-viral":"viral_until","w-squad":"w_squad_until"}.get(id,""),0))
    if id=="absolute-cinema" and game.flex_time>0:return state("FLEX","+20% additive weapon damage during Flex",game.flex_time/float(game.hero.duration),"ffce30")
    if until>now:
        var outside: bool=id=="w-wifi" and game.player_pos.distance_to(t.get("wifi_center",game.player_pos))>160.0
        var strongest: bool=id in ["w-wifi","aura-viral"]
        var actual: float=Rules.weapon_frequency(game.passives,t,now,game.player_pos)-minf(1.0,0.05*game._passive_level("terminally-online")) if strongest else 0.10
        return state("OUT" if outside else "%.0fs" % ceilf(until-now),"Outside Wi-Fi zone · no zone bonus" if outside else "+%s%% %s · %.1fs" % [number(actual*100),"frequency (strongest)" if strongest else "weapon damage",until-now],(until-now)/(4.0 if id=="w-wifi" else 5.0 if id=="aura-viral" else 6.0),"9caebb" if outside else "6ff3df")
    return {}

static func brief(id: String, lv: int) -> String:
    match id:
        "main-character":return "+%d%% weapon damage" % (6*lv)
        "terminally-online":return "+%d%% weapon frequency" % (5*lv)
        "built-different":return "+%d%% max HP" % (8*lv)
        "thick-skin":return "%d%% damage reduction" % (3*lv)
        "caught-4k":return "+%d%% movement speed" % (5*lv)
        "big-meme":return "+%d%% area radius" % (6*lv)
        "timeline":return "+%d%% ranged reach" % (8*lv)
        "hands-on-sight":return "+%d%% damage within 150 U" % (7*lv)
        "cope-harder":return "+%d%% granted Tank shields" % (8*lv)
        "certified-w":return "+%d%% healing and shields" % (6*lv)
        "absolute-cinema":return "+25% weapons; Flex total +45%"
        "w-squad":return "+25% support; Flex dmg +10% / 6s"
        "too-sigma":return "Below 25% HP: 25% shield / 5s"
        "no-u":return "Pulse / 15s; weakens foes in range"
    return ""

static func inspection(id: String, lv: int) -> String:
    # Compact real values for the existing eight-tile build layout. Full
    # conditions remain in describe()/the existing inspection tooltip.
    if id in ["main-character","terminally-online","built-different","thick-skin","caught-4k","big-meme","timeline","hands-on-sight","cope-harder","certified-w"]:
        return brief(id,lv)+(". Does not create a shield." if id=="cope-harder" else ". Added HP capacity only is healed." if id=="built-different" else ". Multiplicative with resistance." if id=="thick-skin" else ".")
    match id:
        "no-cap-streak":return "Every fifth directional activation: +%d pierce, +10%% damage." % lv
        "w-wifi":return "Every 12s: 160 U zone for 4s. +%d%% frequency inside; strongest with Viral." % (8+4*(lv-1))
        "let-him-cook":return "+%d%% damage per stack, max 5. Primary hits refresh the 3s expiry." % (2+lv)
        "homie-check":return "8 primary hits: heal %d%% max HP × support. 6s recovery; hits freeze." % (2+lv)
        "big-chad":return "Every 10s: %d%% HP shield × support, 4s. Refreshes; shared 40%% cap." % (5+2*(lv-1))
        "its-over":return "+%d%% damage to targets below 30%% HP. No execute." % (15+10*(lv-1))
        "aura-viral":return "Flex: +%d%% frequency for 5s. Strongest with Wi-Fi, not additive." % (12+6*(lv-1))
        "so-back":return "Cross below 30%% HP: heal %d%% / 5 ticks × support; 10%% shield / 3s. 45s recovery." % (10+5*(lv-1))
        "six-to-seven":return "Seventh primary hit: 90 U burst, %.2f × base power. Counter freezes for 2s." % (0.35+0.15*(lv-1))
        "absolute-cinema":return "+25% weapon damage; +20% additive during Flex. Does not boost Flex damage."
        "w-squad":return "+25% support permanently. Flex: +10% weapon damage for 6s."
        "too-sigma":return "Cross below 25% HP: 25% HP shield × support / 5s. 60s recovery; no revive."
        "no-u":return "Every 15s: 200 U, 0.30 × power. Enemy damage −20% / 4s; boss −10% / 2s."
    return ""

static func describe(game, id: String, lv: int) -> String:
    var description: String=""
    match id:
        "main-character":description="+%d%% weapon damage." % (6*lv)
        "terminally-online":description="+%d%% weapon frequency (100%% total cap)." % (5*lv)
        "built-different":description="+%d%% max HP. Only added capacity is healed." % (8*lv)
        "thick-skin":description="%d%% damage reduction; multiplicative with resistance." % (3*lv)
        "caught-4k":description="+%d%% movement speed (60%% cap)." % (5*lv)
        "big-meme":description="+%d%% weapon area radius." % (6*lv)
        "timeline":description="+%d%% ranged reach; projectile speed adapts." % (8*lv)
        "hands-on-sight":description="+%d%% weapon damage to targets within 150 U." % (7*lv)
        "cope-harder":description="+%d%% granted Tank shields. Does not create a shield." % (8*lv)
        "certified-w":description="+%d%% healing and granted shields." % (6*lv)
        "no-cap-streak":description="Every fifth directional activation: +%d pierce, +10%% damage." % lv
        "w-wifi":description="Every 12s in combat: 160 U zone, 4s, +%d%% frequency inside. Strongest with Viral." % (8+4*(lv-1))
        "let-him-cook":description="Primary hits: +%d%% damage per stack, max 5. Expires 3s after last hit." % (2+lv)
        "homie-check":description="Every 8 primary hits: heal %d%% max HP × support. 6s recovery; hits freeze." % (2+lv)
        "big-chad":description="Every 10s in combat: %d%% max HP shield × support, 4s. Refreshes; shared 40%% cap." % (5+2*(lv-1))
        "its-over":description="+%d%% damage to targets below 30%% HP; no execute." % (15+10*(lv-1))
        "aura-viral":description="Flex: +%d%% frequency for 5s. Strongest with Wi-Fi, not additive." % (12+6*(lv-1))
        "so-back":description="Cross below 30%% HP: heal %d%% max HP × support in 5 ticks; 10%% shield, 3s. 45s recovery." % (10+5*(lv-1))
        "six-to-seven":description="Seventh primary hit: 90 U burst, %.2f × base power. Counter freezes for 2s." % (0.35+0.15*(lv-1))
        "absolute-cinema":description="+25% weapon damage. During Flex: another +20% additive. Does not boost Flex damage."
        "w-squad":description="+25% support permanently. Flex: +10% weapon damage for 6s."
        "too-sigma":description="Cross below 25% HP: 25% max HP shield × support, 5s; 60s recovery. No revive."
        "no-u":description="Every 15s in combat: 200 U pulse, 0.30 × base power. Enemy damage −20% for 4s; bosses −10% for 2s."
    var live: Dictionary=slot_state(game,id)
    if not live.is_empty():description+="\nNOW: "+str(live.detail)
    return description

func draw_ground(canvas, game) -> void:
    if game.mode!="playing":return
    var reduced: bool=game.profile["settings"].get("reducedMotion",false)
    # One exact zone boundary, below actors, hostile shots and boss telegraphs.
    if game._passive_level("w-wifi")>0 and game.run_time<float(game.passive_timers.get("wifi_until",0)):
        canvas.draw_arc(game.passive_timers.wifi_center,160,0,TAU,40,Color(0.35,0.80,0.85,0.45),1.5,true)
    for effect in rings:
        var life: float=clampf((float(effect.until)-game.run_time)/0.28,0,1)
        var radius: float=float(effect.radius)*(1.0 if reduced else 0.85+0.15*(1.0-life))
        canvas.draw_arc(effect.center,radius,0,TAU,40,Color(0.75,0.64,0.96,0.50 if reduced else life*0.55),2,true)
