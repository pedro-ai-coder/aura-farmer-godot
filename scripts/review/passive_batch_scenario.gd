extends RefCounted
## EXPERIMENTAL controlled legal builds, actual Solo damage/heal/shield/Flex resolvers.
const IDS := ["big-chad","too-sigma","so-back","w-squad","absolute-cinema","combined"]
const NAMES := ["CHAD ARMOR","LAST STAND","COMEBACK SURGE","WINNING CREW","CINEMATIC FLEX","CHAD + SO BACK + W SQUAD"]
const EFFECTS := ["10s: actual shield / 4s","Cross below 25%: shield / 5s; no revive",
    "Cross below 30%: shield + 5 actual healing ticks","Flex: +10% weapon damage / 6s; +25% support",
    "+25% weapons; Flex adds +20% weapons (not Flex damage)","One legal legendary; shields, healing and Flex amplification"]
const World := preload("res://scripts/solo_world_rules.gd")
const EnemyRules := preload("res://scripts/solo_enemy_rules.gd")
const Recorder := preload("res://scripts/review/passive_batch_recorder.gd")
var selected: int
var density: int
var candidate: bool
var stage := 0
var origin := 0.0
var recorder: RefCounted

func _init(index: int, crowd: int, proposed: bool) -> void:
    selected=index;density=crowd;candidate=proposed

func prepare(game) -> void:
    stage=0
    game.passive_feedback = load("res://scripts/review/passive_batch_feedback.gd").new() if candidate else game.PassiveFeedbackScript.new()
    game.passive_feedback.suppress_six_to_seven_ring=true
    var ids: Array = [IDS[selected]] if selected < 5 else ["big-chad","so-back","w-squad"]
    for id: String in ids:
        game._apply_card({"type":"passive","id":id,"rarity":game.SoloOfferRulesScript.PASSIVE_DATA[id].rarity,"level":1})
    # Advance the controlled initial clock, never the passive's first-activation rule.
    game.run_time=8.75 if selected in [0,5] else 0.0
    origin=game.run_time
    game.spawn_timer=INF
    game.enemies.clear()
    for i in (36 if density == 2 else 5):
        var angle := TAU*float(i)/(36.0 if density == 2 else 5.0)
        var kind := "beta" if i%3 == 0 else "npc"
        var radius: float = EnemyRules.DATA[kind].radius
        for attempt in 12:
            var point: Vector2 = game.player_pos+Vector2.from_angle(angle+attempt*0.23)*(115.0+28.0*(i%4))
            if World.walkable(point,radius,game.map_geometry):
                game._spawn_enemy(kind,{"pos":point,"add":true})
                # Stationary legal actors isolate repeatable real activations from survival skill.
                game.enemies[-1].speed=0.0
                game.enemies[-1].hp=10000.0
                game.enemies[-1].max=10000.0
                break
    if selected in [1,2,5]: game.hp=game.max_hp*0.32
    recorder=Recorder.new()
    recorder.start(game,{"commit":ProjectSettings.get_setting("qa/source_commit","local-uncommitted")})
    if candidate: game.passive_feedback.install(game,recorder)
    print("Batch QA start: ",JSON.stringify({"passive":IDS[selected],"candidate":candidate,"density":density,"map":game.map_id,"start":origin}))

func tick_inputs(game) -> void:
    var elapsed: float = game.run_time-origin
    if game.mode != "playing": return
    if stage == 0 and elapsed >= (1.45 if selected == 5 else 1.25):
        stage=1
        if selected in [1,2,5]:
            var resist: float = game.hero.resist
            game._deal_damage_to_player(game.max_hp*0.15/(1.0-resist))
        if selected in [3,4,5]:
            game.aura=100.0
            game._use_flex()
        recorder.event(game,"controlled_input",{"stage":stage,"hp":game.hp,"shield":game.shield,"flex":game.flex_time})
        print("Batch QA input: ",JSON.stringify({"stage":stage,"hp":game.hp,"shield":game.shield,"flex":game.flex_time}))
    elif stage == 1 and elapsed >= (1.85 if selected == 5 else 1.65):
        stage=2
        if selected in [0,1,5]: game._deal_damage_to_player(5.0)

func status_label(game) -> String:
    var count: int = game.passive_feedback.event_count if candidate else 0
    return "EXP / %s / %s / %s / R: RETRY\n%s / HP %.1f / SHIELD %.1f / EVENTS %d" % [NAMES[selected],"CANDIDATE" if candidate else "BASELINE","DENSE" if density==2 else "NORMAL",EFFECTS[selected],game.hp,game.shield,count]

func frame(game) -> void:
    if recorder != null: recorder.frame(game,0)

func finish(game) -> void:
    if recorder != null and recorder.enabled:
        recorder.stop(game,"retry-or-exit")
        print("Batch QA recorder: ",JSON.stringify(recorder.summary()))
