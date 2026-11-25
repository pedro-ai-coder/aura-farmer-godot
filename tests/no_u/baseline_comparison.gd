extends SceneTree

const Maps := preload("res://scripts/solo_maps.gd")

class Run extends "res://scripts/solo_run.gd":
    func _load_profile() -> void:
        profile = ProfileStoreScript.defaults()
        profile.settings.sound = false

    func _save_profile() -> void:
        pass


func _initialize() -> void:
    compare.call_deferred()


func compare() -> void:
    var game := Run.new()
    root.add_child(game)
    game.set_process(false)
    var snapshot: Dictionary = {}
    for map: StringName in Maps.NAMES:
        game._return_to_menu()
        game.open_map_select(0)
        game.start_selected_map(map)
        game._apply_card({"type": "passive", "id": "no-u", "rarity": "legendary", "level": 1})
        if "candidate" in OS.get_cmdline_user_args():
            game.set("no_u_vfx", load("res://scripts/vfx/no_u_counter_pulse.gd").new())
        game.spawn_timer = INF
        game.run_time = 15.0
        game._tick_passives(1.0 / 60.0)
        var waiting: float = game.passive_timers.no_u_next
        game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(200, 0)})
        game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(200.01, 0)})
        game._spawn_enemy("beta", {"pos": game.player_pos + Vector2(85, 0), "elite": true})
        game._spawn_enemy("mod-supremo", {"pos": game.player_pos + Vector2(0, 150)})
        game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(-90, 0), "telegraph": true})
        game._spawn_enemy("npc", {"pos": game.player_pos + Vector2(0, -90)})
        game.enemies[-1].hp = 1.0
        game._tick_passives(1.0 / 60.0)
        var normal := game.enemies[2]
        var boss := game.enemies[3]
        var incoming: Array[float] = []
        for specification in [[16.999, boss], [17.0, boss], [18.999, normal], [19.0, normal]]:
            game.run_time = specification[0]
            game.hp = game.max_hp
            game._deal_damage_to_player(10.0, specification[1])
            incoming.append(snappedf(game.max_hp - game.hp, 0.0001))
        var frames: Array[String] = []
        for index in 660:
            game._process(1.0 / 60.0)
            var state := [game.run_time, str(game.rng.state), game.player_pos, game.hp, game.passive_timers,
                game.enemies, game.passives, game.weapons, game.mode, game.kills, game.total_xp, game.run_metrics,
                game.pickups, game.hostile_shots, game.hazard_zones, game.player_shots]
            var hash_context := HashingContext.new()
            hash_context.start(HashingContext.HASH_SHA256)
            hash_context.update(var_to_bytes(state))
            frames.append(hash_context.finish().hex_encode())
        snapshot[map] = {"damage_received_at_expiry": incoming, "empty_at_15_stayed_pending": waiting == 15.0,
            "paired_frames": frames.size(), "state_stream_sha256": JSON.stringify(frames).sha256_text()}
    var out := FileAccess.open(OS.get_cmdline_user_args()[0], FileAccess.WRITE)
    out.store_string(JSON.stringify(snapshot, "  "))
    out.close()
    game.free()
    quit()
