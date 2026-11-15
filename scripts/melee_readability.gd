extends RefCounted
## Read-only contextual starter trigger-distance cue; never grants reach or a hit.
const CPK=preload("res://scripts/cpk_design_system.gd")
static func snapshot(game) -> Dictionary:
    if game.mode!="playing" or game.hero.is_empty() or game.hero["role"]=="ranged":return {}
    var starter: String=game.hero["starter"]
    var equipped:=false
    for weapon in game.weapons:
        if weapon["id"]==starter:equipped=true;break
    if not equipped:return {}
    var reach: float=game.WEAPONS[starter]["range"]
    var target: Dictionary=game._nearest_target(reach+56.0)
    if target.is_empty():return {}
    var gap: float=game.player_pos.distance_to(target["pos"])
    return {"reach":reach,"origin":game.player_pos,"target":target["pos"],"heading":game._aim_direction(target).angle(),"in_reach":gap<=reach,"enemy_id":target["id"]}
static func draw_ground(canvas: CanvasItem,game) -> void:
    var cue:=snapshot(game)
    if cue.is_empty():return
    var heading: float=cue["heading"]
    var alpha: float=.58 if cue["in_reach"] else .24
    var color:=Color(CPK.PAPER,alpha)
    canvas.draw_arc(cue["origin"],cue["reach"],heading-.26,heading+.26,16,color,1.5,true)
    for side in [-1,1]:
        var direction:=Vector2.from_angle(heading+side*.26)
        canvas.draw_line(cue["origin"]+direction*(cue["reach"]-4),cue["origin"]+direction*(cue["reach"]+3),color,1.5,true)
