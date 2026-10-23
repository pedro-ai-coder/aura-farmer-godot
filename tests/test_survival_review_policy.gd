extends SceneTree

# Review-only controller policy tests. No game-balance overrides or outcome grants.
const Policy = preload("res://tests/survival_review_policy.gd")
const Recovery = preload("res://scripts/recovery_rules.gd")
var failures: Array[String] = []

func _initialize() -> void:
    call_deferred("_verify")

func _expect(condition: bool, description: String) -> void:
    if not condition:
        failures.append(description)

func _verify() -> void:
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    game.start_run(0)
    game.rng.seed = 451
    game.player_pos = Vector2(700,550)
    var patrol := Vector2(760,690)

    game.hp = 30.0
    game.pickups.append({"kind":"snack","pos":Vector2(910,550),"xp":0.0})
    var choice: Dictionary = Policy.goal(game,patrol)
    _expect(choice["kind"] == "snack","Critical health should pursue a valid snack 210U away instead of using legacy 65U gating")
    _expect(choice["pos"] == Vector2(910,550),"Snack target is the actual item position")

    game.hp = game.max_hp
    choice = Policy.goal(game,patrol)
    _expect(choice["kind"] == "patrol","Full-health play should not chase snacks or visit the station")

    game.pickups.clear()
    game.pickups.append({"kind":"magnet","pos":Vector2(890,550),"xp":0.0})
    game.pickups.append({"kind":"aura","pos":Vector2(750,610),"xp":600.0})
    choice = Policy.goal(game,patrol)
    _expect(choice["kind"] == "magnet","When XP waits on the ground, the controller can pursue Magnet beyond 65U")
    game.pickups = [{"kind":"magnet","pos":Vector2(890,550),"xp":0.0}]
    choice = Policy.goal(game,patrol)
    _expect(choice["kind"] == "patrol","No incentive to pursue Magnet with zero waiting XP")

    game.pickups.clear()
    game.player_pos = Vector2(1080,565)
    game.hp = 35.0
    game.run_time = 100.0
    game.safe_spot_ready_at = 99.0
    choice = Policy.goal(game,patrol)
    _expect(choice["kind"] == "station","A ready station should be an explicit recovery objective")
    var stay: Vector2 = Policy.movement(game,choice)
    _expect(stay == Vector2.ZERO,"Safely inside the station, the controller should hold position to charge")
    game.safe_spot_ready_at = 180.0
    choice = Policy.goal(game,patrol)
    _expect(choice["kind"] != "station","The controller must respect the actual station cooldown")

    game.start_run(1)
    game.rng.seed = 451
    game.player_pos = Vector2(700,550)
    game.aura = 100.0
    game._spawn_enemy("npc",{"pos":Vector2(800,550)})
    var enemy_count: int = game.enemies.size()
    var rng_state: int = game.rng.state
    var initial_aura: float = game.aura
    var selected: Dictionary = Policy.aim_target(game)
    _expect(not selected.is_empty() and selected["id"] == game.enemies[0]["id"],"Cool Kid should aim a nearby live enemy before starting the keyboard combo")
    _expect(Policy.should_use_flex(game,selected),"Cool Kid should use his Flex only when a legal close-range target is available")
    game.enemies[0]["pos"] = Vector2(1010,550)
    _expect(not Policy.should_use_flex(game,Policy.aim_target(game)),"Cool Kid should not spend Aura when the closest enemy is out of combo range")

    game.start_run(0)
    game.rng.seed = 451
    game.player_pos = Vector2(700,550)
    game.aura = 100.0
    _expect(not Policy.should_use_flex(game,Policy.aim_target(game)),"Sigma should not spend Aura with no legal priority target")
    game._spawn_enemy("npc",{"pos":Vector2(800,550)})
    _expect(Policy.should_use_flex(game,Policy.aim_target(game)),"Sigma should activate when a legal target exists")

    game.start_run(2)
    game.rng.seed = 451
    game.player_pos = Vector2(700,550)
    game.aura = 100.0
    game._spawn_enemy("npc",{"pos":Vector2(790,550)})
    _expect(Policy.should_use_flex(game,Policy.aim_target(game)),"Alpha can enter his shield/slam window near enemies")
    var no_move: Dictionary = {"kind":"station","pos":Recovery.SAFE_SPOT}
    var before_rng: int = game.rng.state
    var before_hp: float = game.hp
    var before_aura: float = game.aura
    for i in range(2):
        Policy.goal(game,patrol)
        Policy.aim_target(game)
        Policy.movement(game,no_move)
        Policy.should_use_flex(game,Policy.aim_target(game))
    _expect(before_rng == game.rng.state,"Review policy must not advance gameplay RNG")
    _expect(before_hp == game.hp and before_aura == game.aura and game.enemies.size() == 1,"Review policy must not grant HP, Aura or alter active enemies")
    _expect(enemy_count == 1 and initial_aura == 100.0 and rng_state != 0,"The pre-combat Cool Kid fixture was a legitimate normal game state")

    game.queue_free()
    if failures.is_empty():
        print("PASS: Strategic review controller routes actual recovery, respects station/Flex gates and leaves simulation unchanged")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        quit(1)
