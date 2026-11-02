extends SceneTree
const Trace=preload("res://tests/frame_pacing/state_trace.gd")
class Review extends "res://qa/review_run.gd":
    func _ready() -> void:qa_ui_enabled=false;super._ready()
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
class Ordinary extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:profile=ProfileStoreScript.defaults()
    func _save_profile() -> void:pass
var failures: Array[String]=[]
func _initialize() -> void:call_deferred("verify")
func expect(ok: bool,message: String) -> void:
    if not ok:failures.append(message)
func snapshot(game) -> PackedByteArray:
    var state: Array=[game.rng.state,game.profile,game.hero_appearance]
    for key in Trace.KEYS:state.append(game.get(key))
    return var_to_bytes(state)
func count(recorder,kind: String) -> int:
    var total:=0
    for line: String in recorder.lines:
        if JSON.parse_string(line).event==kind:total+=1
    return total
func verify() -> void:
    var a:=Ordinary.new();var b:=Review.new()
    root.add_child(a);root.add_child(b)
    for game in [a,b]:game.set_process(false);game.clean_cut_skin.set_process(false)
    expect(not b.recorder.enabled and b.recorder.lines.is_empty(),"Recording defaults OFF")
    var comparisons:=0
    for appearance in ["original","female"]:
        for hero in range(3):
            b.recorder.start(b,{"commit":"test-fixture"})
            for game in [a,b]:game.hero_appearance=appearance;game.start_run(hero);game.rng.seed=451
            for frame in range(360):
                for game in [a,b]:
                    game.touch_direction=Vector2.from_angle(frame*0.03)
                    if frame==20:game._toggle_pause()
                    if frame==24:game._toggle_pause()
                    if frame==40:game._apply_card({"type":"passive","id":"main-character","rarity":"common","level":1})
                    if frame==50:game._apply_card({"type":"upgrade_passive","id":"main-character","rarity":"common","level":2})
                    if frame==70:game._spawn_enemy("reply-guy",{"pos":Vector2(800,500)})
                    if frame==100:game._deal_damage_to_player(10)
                    if frame==110:game._heal_player(3,"test")
                    if frame==120:game._gain_xp(100)
                    if frame==130:game.aura=100;game._use_flex()
                    game._process([0.008,0.033,0.075,0.016,0.12,0.25][frame%6])
                expect(snapshot(a)==snapshot(b),"Full state/RNG/save parity %s/%d frame %d" % [appearance,hero,frame]);comparisons+=1
            expect(count(b.recorder,"upgrade_committed")==2,"Exactly two real upgrades")
            var previous:=count(b.recorder,"upgrade_committed")
            b._apply_card({"type":"passive","id":"invalid","rarity":"common","level":1})
            expect(count(b.recorder,"upgrade_committed")==previous,"Invalid choice is not logged as acquired")
            b.recorder.stop(b)
    b.start_run(0);b.recorder.start(b,{"commit":"test-fixture"})
    b.run_time=134.99;b._process(0.02)
    expect(count(b.recorder,"spawn")>0,"Real event boundary spawn")
    b.run_time=599.99;b._process(0.02)
    expect(b.boss_spawned and count(b.recorder,"boss_phase")>0,"Boss entry boundary")
    b.mode="playing";b._deal_damage_to_player(100000)
    expect(b.mode=="lost" and count(b.recorder,"run_finished")==1,"Fatal actual damage closes run")
    b.start_run(1);b._finish(true)
    expect(count(b.recorder,"run_finished")==2,"Victory and retry observed")
    expect(b.recorder.run_number==2,"Retry starts second numbered run")
    b.recorder.mark(b);b.recorder.stop(b)
    var path:="res://tests/qa_recorder/evidence/contract-session.zip"
    expect(b.recorder.export_zip(path,FileAccess.get_file_as_string("res://qa/README.md"))==OK,"Four-file ZIP export")
    var zip:=ZIPReader.new();expect(zip.open(path)==OK,"ZIP opens")
    expect(zip.get_files().size()==4,"Exactly four files")
    expect(JSON.parse_string(zip.read_file("session-summary.json").get_string_from_utf8()).runs==2,"Summary parses")
    zip.close()
    b.recorder.start(b,{"commit":"test-fixture"});b.recorder.bytes_used=b.recorder.MAX_BYTES-1
    b.recorder.event(b,"overflow")
    expect(b.recorder.full and not b.recorder.enabled,"Capacity stops without recursion or gameplay stop")
    expect(b.mode=="won","Capacity leaves game mode alone")
    b.recorder.start(b,{"commit":"test-fixture"})
    b.recorder.frame(b,0)
    var samples:=count(b.recorder,"sample")
    for i in range(10):b.recorder.frame(b,0)
    expect(count(b.recorder,"sample")==samples,"No sampling burst between wall-clock deadlines")
    b.recorder.lines.resize(b.recorder.MAX_RECORDS)
    b.recorder.event(b,"record-limit")
    expect(b.recorder.full and not b.recorder.enabled,"Record count is bounded independently of bytes")
    a.queue_free();b.queue_free()
    if failures.is_empty():print("PASS: ",comparisons," exact state/RNG/profile comparisons; six appearances; pause, upgrades, event/boss boundaries, defeat/victory/retry, export and bounded memory");quit()
    else:
        for failure in failures:push_error(failure)
        quit(1)
