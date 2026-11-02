extends SceneTree
## Review-only deterministic scenario contracts; never run state injection in production.
const RULES=preload("res://qa/scenarios.gd")
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool,why: String) -> void:
    if not ok:failures.append(why)
func snapshot(game) -> PackedByteArray:
    return var_to_bytes([game.hero["id"],game.hero_appearance,game.run_time,
        game.wave,game.level,game.total_xp,game.hp,game.max_hp,game.shield,
        game.event_index,game.legendary_spent,game.rng.state,
        game.weapons,game.passives,game.enemies,game.passive_timers])

func verify() -> void:
    var before:=FileAccess.get_file_as_bytes("user://profile_v2.json") if FileAccess.file_exists("user://profile_v2.json") else PackedByteArray()
    var game=load("res://qa/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    expect(not game._qa_synthetic and not game.recorder.enabled,"QA and recording default OFF")
    expect(game.qa_settings!=null and game.qa_diagnostics!=null,"Review QA launcher and overlays installed")
    var count:=0
    for scenario: Dictionary in RULES.PRESETS:
        for hero: String in ["sigma","cool-kid","alpha"]:
            for appearance: String in ["original","female"]:
                for style: String in RULES.BUILD_NAMES:
                    game._return_to_menu()
                    var ok: bool=game.start_qa_scenario(str(scenario["id"]),hero,appearance,style,451,{},false)
                    expect(ok,"Scenario launch succeeds for "+str([scenario["id"],hero,appearance,style]))
                    if not ok:continue
                    expect(game._qa_synthetic and game.mode=="playing","Synthetic flag and active play")
                    expect(is_equal_approx(game.run_time,float(scenario["time"])),"Scenario timestamp")
                    expect(game.level==int(scenario["level"]),"Synthetic level")
                    expect(is_equal_approx(game.total_xp,RULES.accumulated_xp(game.level)),"Consistent synthetic cumulative XP")
                    expect(game.wave==mini(5,1+int(game.run_time/120.0)),"Canonical wave clock")
                    expect(RULES.valid_build(game,hero,{"weapons":game.weapons,"passives":game.passives}),"Legal canonical equipment")
                    expect(game.weapons.size()<=3 and game.passives.size()<=5,"Equipment caps")
                    expect(game.hp==game.max_hp,"Valid configured starting health")
                    expect(game.qa_context()["session_type"]=="qa_scenario","Synthetic context")
                    expect(game.rng.seed==451,"Fixed seed")
                    expect(game.boss_spawned==(str(scenario["id"])=="big-hater"),"Boss state at preset")
                    if game.boss_spawned:
                        expect(game.enemies.size()==1 and game.enemies[0]["kind"]=="boss","Canonical boss spawned")
                    var first:=snapshot(game)
                    game._return_to_menu()
                    expect(game.start_qa_scenario(str(scenario["id"]),hero,appearance,style,451,{},false),"Repeat launch")
                    expect(snapshot(game)==first,"Same seed and fixture = same authoritative starting state")
                    count+=1
    game._return_to_menu()
    var invalid: Dictionary=RULES.make_build("sigma","wave5","Balanced")
    invalid["weapons"].append({"id":"keyboard-warrior","rarity":"epic","level":1})
    expect(not RULES.valid_build(game,"sigma",invalid),"Illegal class and over-cap build rejected")
    var wrong: Dictionary=RULES.make_build("sigma","wave5","Balanced")
    wrong["passives"].append({"id":"get-ratiod","rarity":"common","level":1})
    expect(not RULES.valid_build(game,"sigma",wrong),"Future-only passive refused")
    expect(not game.start_qa_scenario("unknown","sigma","original","Balanced",451,{},false),"Unknown scenario refused")
    expect(not game.start_qa_scenario("wave3","sigma","original","Balanced",-1,{},false),"Invalid seed refused")
    expect(game.start_qa_scenario("wave5","sigma","female","Balanced",912,{"threats":true},true),"Synthetic recorder launch")
    expect(game.recorder.metadata.get("session_type")=="qa_scenario","Recorder labels synthetic session")
    expect(game.recorder.metadata.get("scenario_id")=="wave5","Scenario ID in metadata")
    expect(game.recorder.metadata.get("sim_start_time")==480.0,"Simulation timestamp in metadata")
    expect(game.recorder.metadata.get("scenario_config",{}).has("equipment"),"Exact starting equipment in metadata")
    for line: String in game.recorder.lines:
        var row: Dictionary=JSON.parse_string(line)
        expect(row.get("session_type")=="qa_scenario","Every synthetic trace row labeled")
    expect(not game.start_qa_scenario("wave3","sigma","original","Balanced",912,{},false),"Recorded scenario cannot be silently replaced")
    game.recorder.stop(game)
    game._return_to_menu()
    game.qa_ui.clear_session()
    game.start_run(0)
    expect(not game._qa_synthetic and game.qa_context()["session_type"]=="normal_run","Ordinary run resets QA state")
    expect(not game.qa_diagnostics.caption.visible or not game._qa_synthetic,"Synthetic overlay not on ordinary play")
    var after:=FileAccess.get_file_as_bytes("user://profile_v2.json") if FileAccess.file_exists("user://profile_v2.json") else PackedByteArray()
    expect(before==after,"QA fixtures never alter production profile bytes")
    game.queue_free()
    if failures.is_empty():
        print("PASS: ",count," deterministic wave/hero/appearance/build repetitions; 5 scenarios, 3 kits, 2 looks, 3 builds; legal items, seed, boss and tagged recorder")
        quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
