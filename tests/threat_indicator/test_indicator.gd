extends "res://tests/test_clean_cut_pointer_input.gd"
const Overlay=preload("res://scripts/hero_clash_threat_overlay.gd")
class ReviewRun extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var clock_ms:=1000
var reports: Array=[]

func sample_stable(overlay) -> void:
    overlay.sample_at(clock_ms);clock_ms+=400;overlay.sample_at(clock_ms)

func move_bounds(enemy: Dictionary,at: Vector2,overlay,transform: Transform2D) -> void:
    var bounds: Rect2=overlay.enemy_bounds(enemy,transform)
    enemy["pos"]=transform.affine_inverse()*(transform*Vector2(enemy["pos"])+at-bounds.position)

func temporal_tests() -> void:
    var state:=Overlay.BossVisibility.new()
    for i in range(40):state.observe(1.0,0.59 if i%2==0 else 0.61,i*50)
    expect(state.phase==Overlay.Visibility.CLEAR and state.transitions==0,"Entry threshold jitter cannot flicker a new indicator")
    state.observe(1,0.5,2000);state.observe(1,0.5,2179)
    expect(state.phase==Overlay.Visibility.CLEAR,"Entry has a real 180 ms dwell")
    state.observe(1,0.5,2180)
    expect(state.phase==Overlay.Visibility.OCCLUDED and state.transitions==1,"Sustained meaningful occlusion enters once")
    for i in range(30):state.observe(1,0.77 if i%2==0 else 0.79,2200+i*50)
    expect(state.phase==Overlay.Visibility.OCCLUDED and state.transitions==1,"Exit jitter cannot repeatedly hide/show an established cue")
    state.observe(1,0.70,3950);state.observe(1,0.95,4000);state.observe(1,0.95,4299)
    expect(state.phase==Overlay.Visibility.OCCLUDED,"Exit has its own 300 ms dwell")
    state.observe(1,0.95,4300)
    expect(state.phase==Overlay.Visibility.CLEAR and state.transitions==2,"Clear visibility removes the redundant cue after stable recovery")
    state.observe(0,0,4500);state.observe(0,0,4680)
    expect(state.phase==Overlay.Visibility.OFFSCREEN,"A fully offscreen boss remains represented")
    for i in range(30):state.observe(0.31 if i%2==0 else 0.33,0.2,4700+i*50)
    expect(state.phase==Overlay.Visibility.OFFSCREEN and state.transitions==3,"Spatial and temporal hysteresis prevent offscreen/occluded oscillation")
    state.observe(0.20,0.20,6250);state.observe(0.5,0.5,6300);state.observe(0.5,0.5,6499)
    expect(state.phase==Overlay.Visibility.OFFSCREEN,"Changing cue classifications has a 200 ms dwell")
    state.observe(0.5,0.5,6500)
    expect(state.phase==Overlay.Visibility.OCCLUDED and state.transitions==4,"A materially returning silhouette transitions once")

func verify() -> void:
    temporal_tests()
    var game:=ReviewRun.new();root.add_child(game);game.set_process(false);game.clean_cut_skin.set_process(false)
    game.profile["settings"]["reducedMotion"]=true
    var skin=game.clean_cut_skin;var hud=skin.gameplay_hud;var overlay=hud.threat_overlay
    for extent in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
        root.size=extent;game.touch_device=extent.x<1000
        game.web_metrics={"width":extent.x,"height":extent.y,"safe":[24,8,16,12]}
        game.start_run(0);game.run_time=135;game.wave=2;game.player_pos=Vector2(1000,600)
        game.presentation._window_changed(true);game._update_camera(0,true);game._show_ui();game._update_text()
        await process_frame;await process_frame
        skin.layout_key="";skin.refresh();overlay.reset()
        var transform: Transform2D=skin.get_global_transform_with_canvas().affine_inverse()*game.get_global_transform_with_canvas()
        game._spawn_enemy("reply-guy",{"pos":Vector2(750,500)})
        var reply: Dictionary=game.enemies[-1]
        var size: Vector2=overlay.enemy_bounds(reply,transform).size
        var middle:=Vector2(skin.view.x*0.5-size.x*0.5,skin.view.y*0.43)
        var status: Rect2=hud.modules["TopLeftHeroStatus"].get_rect()
        var scenarios: Dictionary={"visible":middle,"slightly_clipped":Vector2(-size.x*0.08,skin.view.y*0.43),"slight_hud_overlap":Vector2(status.position.x+5,status.end.y-size.y*0.15),"meaningfully_clipped":Vector2(-size.x*0.58,skin.view.y*0.43),"hud_occluded":status.position+Vector2(35,18),"offscreen":Vector2(-size.x-64,skin.view.y*0.43)}
        for name in scenarios:
            overlay.reset();move_bounds(reply,scenarios[name],overlay,transform);sample_stable(overlay)
            var required: bool=name in ["meaningfully_clipped","hud_occluded","offscreen"]
            expect(overlay.cue.visible==required,"Meaningful visibility decision: "+name+" "+str(extent))
            if required:
                expect(overlay.cue.text=="REPLY GUY","Only canonical identity is player-facing")
                expect(not overlay.cue.text.contains("EDGE"),"Rendering terminology never leaks to player copy")
                expect(Rect2(Vector2.ZERO,skin.view).encloses(overlay._anchor),"Complete arrow/name marker stays in safe bounds")
                for region in hud.reserved:expect(not overlay._anchor.intersects(region),"Indicator avoids actual permanent HUD")
                expect(game._touch_ui_at(game.layer,overlay.cue.get_global_rect().get_center())==null,"Cue does not own terrain input")
                if name=="offscreen":expect(overlay.current_phase==Overlay.Visibility.OFFSCREEN and overlay.cue_direction.x< -0.8,"Fully offscreen direction uses actual view-to-threat bearing")
                var count: int=overlay.layout_updates;var anchor: Rect2=overlay._anchor
                for i in range(10):
                    move_bounds(reply,scenarios[name]+Vector2(i%2,0),overlay,transform);clock_ms+=50;overlay.sample_at(clock_ms)
                expect(overlay.layout_updates==count and overlay._anchor==anchor,"Small motion cannot churn indicator layout")
            reports.append({"viewport":str(extent),"case":name,"cue":overlay.cue.text if overlay.cue.visible else "","phase":overlay.current_phase,"anchor":str(overlay._anchor)})
        # Stable identity selection, independent of enemy-array iteration order.
        overlay.reset();move_bounds(reply,Vector2(-size.x-64,skin.view.y*0.43),overlay,transform)
        game._spawn_enemy("mod-supremo",{"pos":Vector2(1250,500)})
        var mod: Dictionary=game.enemies[-1]
        move_bounds(mod,Vector2(-size.x-70,skin.view.y*0.60),overlay,transform)
        game.enemies.reverse();sample_stable(overlay)
        expect(overlay.current_id==reply["id"] and overlay.cue.text=="REPLY GUY","Equal event threats use stable IDs")
        game.enemies.reverse();sample_stable(overlay)
        expect(overlay.current_id==reply["id"] and overlay.get_child_count()==1,"Array order cannot duplicate or alternate labels")
        game.run_time=725;game.wave=5;game.boss_spawned=true;game._spawn_enemy("boss",{"pos":Vector2(1200,600)})
        var final_boss: Dictionary=game.enemies[-1]
        move_bounds(final_boss,Vector2(-size.x-120,skin.view.y*0.4),overlay,transform)
        game._show_ui();game._update_text();skin.layout_key="";skin.refresh();sample_stable(overlay)
        expect(overlay.current_id==final_boss["id"] and overlay.cue.text=="BIG HATER","Eligible final Big Hater takes priority over event threats")
        var final_direction: Vector2=(overlay.enemy_bounds(final_boss,transform).get_center()-skin.view*0.5).normalized()
        expect(overlay.cue_direction.dot(final_direction)>0.999,"Directional cue follows the current world-to-screen transform")
        # Real-engine recording exposed a two-frame lower-priority flash while
        # multiple silhouettes returned at slightly different times.
        move_bounds(final_boss,Vector2(skin.view.x*0.65,skin.view.y*0.45),overlay,transform)
        clock_ms+=50;overlay.sample_at(clock_ms)
        clock_ms+=200;move_bounds(reply,middle,overlay,transform)
        move_bounds(mod,Vector2(skin.view.x*0.30,skin.view.y*0.50),overlay,transform);overlay.sample_at(clock_ms)
        clock_ms+=100;overlay.sample_at(clock_ms)
        expect(not overlay.cue.visible,"Returning final boss cannot briefly hand off to an event about to clear")
        clock_ms+=50;overlay.sample_at(clock_ms)
        expect(not overlay.cue.visible,"Lower-priority handoff has a stable 160 ms guard")
        clock_ms+=200;overlay.sample_at(clock_ms)
        expect(not overlay.cue.visible,"Stable fully visible actors leave no redundant marker")
        move_bounds(reply,Vector2(-size.x-64,skin.view.y*0.43),overlay,transform)
        final_boss["hp"]=0;sample_stable(overlay)
        expect(overlay.current_id==reply["id"],"A defeated threat cannot retain priority")
        # Actual attack boundary remains independent of label suppression.
        game.enemies.assign([reply]);move_bounds(reply,middle,overlay,transform);overlay.reset();sample_stable(overlay)
        expect(not overlay.cue.visible,"Visible Reply Guy does not carry a decorative nameplate")
        for shape in ["circle","cone","ring","line","tether"]:
            game.hazard_zones.clear()
            var point: Vector2=transform.affine_inverse()*Vector2(30,50)
            game._schedule_hazard(point,260,0.8,0.2,18,shape,Vector2.RIGHT,reply)
            var simulation: String=var_to_str([game.enemies,game.hazard_zones,game.rng.state,game.player_pos,game.camera.position,game.camera.zoom,game.run_time,game.hp])
            sample_stable(overlay)
            expect(not overlay.cue.visible,"Attack boundaries do not create redundant boss nameplates: "+shape)
            if shape in ["line","tether"]:expect(not overlay.traces.is_empty(),"Live hostile boundary crosses occupied HUD even with no cue")
            expect(var_to_str([game.enemies,game.hazard_zones,game.rng.state,game.player_pos,game.camera.position,game.camera.zoom,game.run_time,game.hp])==simulation,"Overlay never changes simulation or attack timing: "+shape)
        var identity: Array[CanvasItem]=[skin.player_plate,skin.portrait,skin.hero_name,skin.wave_frame,skin.wave,hud.wave_clock,hud.strip,hud.ability_plate]
        for node in identity:expect(node.visible and node.self_modulate.a==1,"Permanent HUD remains visible and opaque")
        expect(skin.aura_arc.body_alpha==1 and not skin.hp.has_theme_stylebox_override("normal"),"No temporary replacement HUD styles")
        for reduced in [true,false]:
            game.profile["settings"]["reducedMotion"]=reduced;move_bounds(reply,scenarios["offscreen"],overlay,transform);sample_stable(overlay)
            expect(overlay.cue.visible and not overlay.is_processing(),"Reduced Motion keeps static functional direction without animation")
        game._toggle_pause();overlay.sample_at(clock_ms+50)
        expect(not overlay.visible and overlay.states.is_empty(),"Pause clears transient cue ownership")
        game._toggle_pause();sample_stable(overlay)
        expect(overlay.cue.visible,"Resume reacquires the real active threat")
        for won in [false,true]:
            game._finish(won);overlay.sample_at(clock_ms+50)
            expect(not overlay.cue.visible and overlay.states.is_empty(),"Result freezes and clears threat presentation")
            game.start_run(0);overlay.sample_at(clock_ms+100)
            expect(overlay.states.is_empty() and not overlay.cue.visible,"Restart cannot inherit a stale boss or label")
    game.queue_free()
    var args:=OS.get_cmdline_user_args()
    if not args.is_empty():
        var file:=FileAccess.open(args[0],FileAccess.WRITE);file.store_string(JSON.stringify({"cases":reports,"failures":failures},"  "));file.close()
    if failures.is_empty():print("PASS: Threat visibility thresholds/dwell, offscreen direction, deterministic priority, six safe viewports, unchanged HUD/simulation and lifecycle");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
