extends "res://tests/no_u/test_counter_pulse.gd"
const Batch := preload("res://scripts/review/passive_batch_scenario.gd")
var events_a: Array = []
var events_b: Array = []

func run() -> void:
    var before := ReviewRun.new()
    var after := ReviewRun.new()
    for game: ReviewRun in [before,after]:
        root.add_child(game)
        game.set_process(false)
        game.clean_cut_skin.set_process(false)
    var comparisons := 0
    var activations := {}
    for map: StringName in Maps.NAMES:
        for density in [1,2]:
            for reduced in [false,true]:
                for index in 6:
                    for game: ReviewRun in [before,after]:
                        game._return_to_menu()
                        game.profile = game.ProfileStoreScript.defaults()
                        game.profile.settings.sound = false
                        game.profile.settings.reducedMotion = reduced
                        game.map_id=map
                        game.batch_review=Batch.new(index,density,game==after)
                        game.start_run(2)
                    for frame in 480:
                        before._process(STEP)
                        after._process(STEP)
                        if state(before)!=state(after):
                            check(false,"Batch changed authoritative state %s/%d/%s/%d/%d" % [map,density,reduced,index,frame])
                            break
                        check(after.passive_feedback.bursts.size()<=8,"Unbounded burst queue")
                        comparisons += 1
                    var records: PackedStringArray = after.batch_review.recorder.lines
                    var ids := {}
                    var heals := 0
                    for line in records:
                        var record: Dictionary = JSON.parse_string(line)
                        if record.event != "passive_vfx": continue
                        ids[record.data.id]=true
                        if record.data.kind=="heal":
                            heals+=1
                            check(record.data.value>0.0,"False healing VFX")
                    for id: String in ([Batch.IDS[index]] if index<5 else ["big-chad","so-back","w-squad"]):
                        check(ids.has(id),"Missing actual activation "+id)
                        activations[id]=true
                    if index in [2,5]: check(heals==5,"So Back must show five effective heal ticks")
                    if index in [0,1]: check(after.shield==0.0,"Expired shield retained protection")
                    check(before.profile_writes==0 and after.profile_writes==0,"QA wrote progression")
    # A fully capped/zero grant and a zero heal must remain visually silent.
    after.start_run(2)
    var observer = after.passive_feedback
    var count: int = observer.event_count
    observer.healed(after,"so-back",0.0)
    observer.shield_granted(after,"big-chad",0.0,4.0)
    check(observer.event_count==count,"Zero outcome created VFX")
    after._return_to_menu()
    check(after.batch_review==null and after.passive_feedback.get_script().resource_path=="res://scripts/passive_feedback.gd","Candidate leaked to ordinary run")
    before.free();after.free()
    print("Batch 01: %d exact state/RNG/profile paired frames; %d passive IDs; failures %d" % [comparisons,activations.size(),failures])
    quit(1 if failures else 0)
