extends "res://scripts/solo_run.gd"
## Controlled review only: canonical simulation, isolated non-persistent profile.
func _load_profile() -> void:profile=ProfileStoreScript.defaults()
func _save_profile() -> void:pass
func fixture(id: String, appearance: String, dense: bool=false) -> void:
    hero_appearance=appearance
    var index:=0 if id in ["no-cap","ratio-blaster","brainrot-feed"] else 1 if id in ["keyboard-warrior","ban-hammer","touch-grass"] else 2
    start_run(index);set_process(false);clean_cut_skin.set_process(false)
    weapons.assign([{"id":id,"level":1,"rarity":"common","timer":0.15}])
    player_pos=Vector2(770,550);spawn_timer=INF
    manual_aim=true;aim_point=player_pos+Vector2(400,0)
    for i in range(100 if dense else 4):
        var point:=player_pos+Vector2((270.0 if index==0 else 65.0)+i*18.0,(-1.0 if i%2 else 1.0)*i*14.0)
        if dense:point=player_pos+Vector2.from_angle(i*2.399963)*float(130+(i%9)*29)
        if SoloWorldRulesScript.walkable(point,18):_spawn_enemy(["npc","hater","beta"][i%3],{"pos":point})
    if dense:
        run_time=548;wave=5;level=20;hp=10000;max_hp=10000
        legendary_spent=true
        weapons.assign([{"id":"cope-shield","rarity":"common","level":4,"timer":0.0},{"id":"chad-hands","rarity":"common","level":4,"timer":0.0},{"id":"personal-space","rarity":"common","level":4,"timer":0.0}])
        for i in range(80):pickups.append({"kind":"aura","xp":5.0,"pos":player_pos+Vector2.from_angle(i*2.399963)*float(110+i%9*25)})
        _spawn_enemy("boss",{"pos":Vector2(1030,540)})
        var boss: Dictionary=enemies[-1]
        _schedule_hazard(boss.pos,360,0.8,0.1,60,"line",Vector2.LEFT,boss)
    _update_camera(0,true);presentation._window_changed(true);_show_ui();_update_text()
    clean_cut_skin.layout_key="";clean_cut_skin.refresh();queue_redraw()
