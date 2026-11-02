extends "res://scripts/solo_run.gd"
## Review-only subclass. Every rule delegates to the unchanged canonical run.
const Recorder = preload("res://qa/recorder.gd")
var recorder = Recorder.new()
var qa_ui
var qa_ui_enabled := true
func _ready() -> void:
    super._ready()
    if qa_ui_enabled:
        qa_ui=load("res://qa/toolbar.gd").new();add_child(qa_ui);qa_ui.install(self)
func _process(delta: float) -> void:
    if not recorder.enabled:
        super._process(delta);return
    var started := Time.get_ticks_usec()
    super._process(delta)
    recorder.frame(self,Time.get_ticks_usec()-started)
func _show_ui() -> void:
    super._show_ui()
    recorder.observe_mode(self)
func start_run(index: int) -> void:
    var previous := run_id
    super.start_run(index)
    if run_id!=previous:recorder.run_started(self)
func _spawn_enemy(kind: String, special: Dictionary = {}) -> void:
    var previous := next_enemy_id
    super._spawn_enemy(kind,special)
    if recorder.enabled and next_enemy_id!=previous:
        recorder.spawn_counts[kind]=int(recorder.spawn_counts.get(kind,0))+1
        recorder.event(self,"spawn",{"id":next_enemy_id-1,"kind":kind,"elite":enemies.back().elite,"add":enemies.back().add})
func _hit_enemy(enemy: Dictionary, amount: float, primary: bool=false, weapon: bool=false) -> void:
    var watched: bool=recorder.enabled and enemies.has(enemy)
    var previous := float(run_metrics.get("damage",0)) if watched else 0.0
    super._hit_enemy(enemy,amount,primary,weapon)
    if watched and recorder.enabled:
        var actual := float(run_metrics.get("damage",0))-previous
        recorder.damage_by_type[enemy.kind]=float(recorder.damage_by_type.get(enemy.kind,0))+actual
        if float(enemy.hp)<=0 and not enemies.has(enemy):recorder.event(self,"kill",{"id":enemy.id,"kind":enemy.kind,"xp_value":enemy.xp,"boss":SoloEnemyRulesScript.DATA[enemy.kind].boss})
func _deal_damage_to_player(amount: float, source: Dictionary={}, contact: bool=false, hazard: bool=false) -> void:
    var previous_hp := hp
    var previous_protection := float(run_metrics.get("protection",0))
    super._deal_damage_to_player(amount,source,contact,hazard)
    if recorder.enabled:
        var lost := maxf(0,previous_hp-hp)
        var absorbed := float(run_metrics.get("protection",0))-previous_protection
        if lost+absorbed>0:
            var key := "%s/%s" % [source.get("kind","unknown"),"hazard" if hazard else "contact" if contact else "direct"]
            recorder.taken_by_source[key]=float(recorder.taken_by_source.get(key,0))+lost
            recorder.event(self,"damage_taken",{"source":key,"hp_lost":lost,"absorbed":absorbed,"hp":hp})
func _heal_player(amount: float, feedback_source: String="") -> void:
    var before := hp
    super._heal_player(amount,feedback_source)
    if recorder.enabled and hp>before:recorder.event(self,"heal",{"source":feedback_source if not feedback_source.is_empty() else "unspecified","effective":hp-before,"hp":hp})
func _gain_xp(amount: float) -> void:
    var old_xp := total_xp
    var old_level := level
    var old_hp := hp
    super._gain_xp(amount)
    if recorder.enabled and total_xp>old_xp:
        recorder.event(self,"xp",{"gained":total_xp-old_xp,"total":total_xp,"from_level":old_level,"level":level,"hp_delta":hp-old_hp})
func _apply_card(card: Dictionary, replace_id: String="") -> void:
    if not recorder.enabled:super._apply_card(card,replace_id);return
    var before := Recorder.equipment(weapons)+Recorder.equipment(passives)
    var selected := {"type":card.get("type",""),"id":card.get("id",""),"rarity":card.get("rarity",""),"level":card.get("level",0),"replaced":replace_id}
    var pending := pending_choices
    var old_legendary := legendary_spent
    super._apply_card(card,replace_id)
    var after := Recorder.equipment(weapons)+Recorder.equipment(passives)
    if before!=after or pending_choices<pending or legendary_spent!=old_legendary:
        selected["equipment"]=after;recorder.event(self,"upgrade_committed",selected)
func _use_flex() -> void:
    var before := int(run_metrics.get("flexes",0))
    super._use_flex()
    if recorder.enabled and int(run_metrics.get("flexes",0))>before:recorder.event(self,"flex_started",{"hero":hero.id,"aura":aura,"duration":flex_time})
func _finish(won: bool) -> void:
    var before := mode
    super._finish(won)
    if recorder.enabled and mode!=before:
        recorder.event(self,"run_finished",{"outcome":mode,"kills":kills,"level":level,"xp":total_xp});recorder.sample(self)
func qa_build() -> Dictionary:
    if FileAccess.file_exists("res://qa/build.json"):
        var result=JSON.parse_string(FileAccess.get_file_as_string("res://qa/build.json"))
        if result is Dictionary:return result
    return {"commit":"unknown-local-build"}
