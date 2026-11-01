extends "res://scripts/solo_run.gd"
## Review-only deterministic fixtures; never read or write a real player save.
func _load_profile() -> void: profile=ProfileStoreScript.defaults()
func _save_profile() -> void: pass

func fixture(dense: bool) -> void:
    start_run(0)
    set_process(false)
    clean_cut_skin.set_process(false)
    profile["settings"]["reducedMotion"]=true
    run_time=548.0 if dense else 129.0
    wave=5 if dense else 2
    level=20 if dense else 6
    aura=63.0
    hp=71.0
    player_pos=Vector2(780,540)
    spawn_timer=INF
    # Deterministic placement without consuming the gameplay RNG. Canonical
    # enemies, real shots and real world/HUD renderers; not a human playthrough.
    for i in range(100 if dense else 12):
        var angle:=float(i)*2.3999632297
        var distance:=135.0+float(i%9)*30.0
        var point:=player_pos+Vector2.from_angle(angle)*distance
        if SoloWorldRulesScript.walkable(point,18.0):
            _spawn_enemy(["npc","hater","beta","ping-sniper"][i%4],{"pos":point})
    pickups.clear()
    for i in range(180 if dense else 32):
        var angle:=float(i)*2.3999632297
        var distance:=90.0+float(i%13)*23.0
        var point:=player_pos+Vector2.from_angle(angle)*distance
        if SoloWorldRulesScript.walkable(point,10.0):
            pickups.append({"kind":"aura","xp":5.0,"pos":point})
    pickups.append({"kind":"aura","xp":80.0,"phase":2,"pos":Vector2(875,470)})
    pickups.append({"kind":"snack","xp":0.0,"pos":Vector2(705,480)})
    pickups.append({"kind":"magnet","xp":0.0,"pos":Vector2(890,560)})
    # Identical coral hostile projectiles beside the collectibles for context.
    for i in range(4):
        var source: Dictionary=enemies[i]
        source["locked_direction"]=Vector2.LEFT
        _spawn_hostile_shot(source)
        hostile_shots[-1]["pos"]=Vector2(930+i*24,440+i*14)
    _update_camera(0,true)
    presentation._window_changed(true)
    _show_ui();_update_text()
    clean_cut_skin.layout_key="";clean_cut_skin.refresh()
    queue_redraw()
