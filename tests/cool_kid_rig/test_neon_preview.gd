extends SceneTree
const Preview=preload("res://scripts/neon_cool_kid_review.gd")
var failures: Array[String]=[]
func check(ok: bool, label: String) -> void:
    if not ok:failures.append(label)
func _initialize() -> void:call_deferred("verify")
func verify() -> void:
    var garage:=Preview.new();root.add_child(garage)
    var game=garage.game
    check(garage.active and garage.hero_cards.size()==6,"current Neon Garage and six identities")
    check(game.hero_index==1 and game.hero_appearance=="original","Cool Kid review default")
    check(game.art.cool_kid_rig.valid and game.art.cool_kid_rig.enabled,"pinned rig ready")
    check(not game.review_overlay.visible,"review overlay hidden on Garage")
    garage.start_selected();garage._process(0.0)
    check(game.mode=="playing" and not garage.active,"real gameplay reached")
    check(game.review_overlay.visible,"in-game A/B control visible")
    var snapshot=var_to_bytes([game.rng.state,game.hp,game.run_time,game.player_pos,game.weapons])
    game._review_toggle()
    check(not game.art.cool_kid_rig.enabled,"A/B legacy toggle")
    check(snapshot==var_to_bytes([game.rng.state,game.hp,game.run_time,game.player_pos,game.weapons]),"A/B preserves simulation")
    game._review_toggle()
    check(not game.art.cool_kid_rig.supports("cool-kid","female","idle",{}),"Byte Baddie remains legacy")
    garage.queue_free()
    if failures.is_empty():print("PASS: Neon Garage, default Cool Kid, six identities, real run and pure A/B toggle");quit()
    else:
        for message in failures:push_error(message)
        quit(1)
