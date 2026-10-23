extends SceneTree
const Registry = preload("res://scripts/approved_icon_registry.gd")
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
    var empty := Registry.new({"schema_version":1,"icons":[]})
    var live := Registry.new()
    var readiness: Array = JSON.parse_string(FileAccess.get_file_as_string("res://docs/art/v5_icon_readiness.json"))
    var pending: Array[String] = []
    for category in ["weapon","passive"]:
        var ids: Array = []
        for item: Dictionary in readiness:
            if item["kind"] == category: ids.append(item["id"])
        pending.append_array(live.missing_mappings(category,ids))
    for row: Dictionary in JSON.parse_string(FileAccess.get_file_as_string(Registry.MANIFEST))["icons"]:
        if live.texture(row["category"],row["id"]) == null: failures.append("Every approved canonical mapping loads")
    if not live.issues.is_empty(): failures.append("Live manifest has no invalid or missing approved resource")
    print("ICON MAPPINGS PENDING: ",", ".join(pending))
    if not empty.issues.is_empty() or empty.texture("weapon","no-cap") != null or empty.texture("passive","unknown") != null:
        failures.append("Pending and unknown items have an honest null fallback")
    var source := Image.create_empty(32,32,false,Image.FORMAT_RGBA8)
    source.fill(Color.WHITE)
    var diagnostic := ImageTexture.create_from_image(source)
    var loads := {"count":0}
    var loader := func(_path):
        loads["count"] += 1
        return diagnostic
    var row := {"id":"no-cap","category":"weapon","source_sha256":"a".repeat(64),"promoted_sha256":"a".repeat(64),"resource_path":"res://assets/runtime-icons/weapons/no-cap/"+"a".repeat(64)+".png","approval_status":"CREATOR_APPROVED","approval_reference":"TEST FIXTURE ONLY — no creator consent"}
    var registry := Registry.new({"schema_version":1,"icons":[row]},loader)
    if registry.texture("weapon","no-cap") != diagnostic or registry.texture("weapon","no-cap") != diagnostic or loads["count"] != 1:
        failures.append("Approved fixture texture is loaded and cached once")
    if registry.texture("passive","no-cap") != null: failures.append("Categories never borrow similar icons")
    for change in [{"approval_status":"PRODUCTION_CANDIDATE"},{"approval_reference":""},{"resource_path":"res://assets/art-production/source.png"},{"promoted_sha256":"z".repeat(64)}]:
        var bad: Dictionary = row.duplicate(); bad.merge(change,true)
        var rejected := Registry.new({"schema_version":1,"icons":[bad]},loader)
        if rejected.issues.is_empty() or rejected.texture("weapon","no-cap") != null: failures.append("Unsigned or unsafe resource mapping rejected")
    var duplicates := Registry.new({"schema_version":1,"icons":[row,row]},loader)
    if duplicates.issues.is_empty(): failures.append("Duplicate identity mappings rejected")
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    game.start_run(0)
    game.run_time = 360.0
    game._open_legendary() # Controlled legal six-offer setup, before the RNG snapshot.
    var original_passives: Array = game.PASSIVES.duplicate()
    var before := JSON.stringify([game.rng.state,game.weapons,game.passives,game.hp,game.run_time])
    game.presentation.item_icons = registry
    for viewport: Vector2i in [Vector2i(1600,900),Vector2i(1280,720),Vector2i(1920,1080),Vector2i(915,412),Vector2i(390,844)]:
        root.size = viewport
        game.presentation._window_changed(true)
        game.mode = "choice"
        game.selection.assign([{ "id":"no-cap","rarity":"common","level":1,"type":"weapon"}])
        game.presentation.refresh()
        await process_frame
        var parts: Dictionary = game.presentation.card_parts[0]
        if parts["image"].texture != diagnostic or not parts["image"].visible or parts["icon"].visible:
            failures.append("Live card uses approved diagnostic texture without fallback overlay")
        if parts["image"].mouse_filter != Control.MOUSE_FILTER_IGNORE: failures.append("Icon cannot intercept touch or focus")
        if not Rect2(Vector2.ZERO,game.offer_buttons[0].size).encloses(Rect2(parts["image"].position,parts["image"].size)):
            failures.append("Texture stays inside card after resize")
        game.mode = "build"
        game.presentation.refresh()
        if game.presentation.equipment_slots[0]["image"].texture != diagnostic: failures.append("Build slots share the exact card identity")
        game.mode = "legendary"
        game.presentation.refresh()
        if game.legendary_offers.size() != 6 or not game.offer_buttons[5].visible: failures.append("Registry preserves all six legendary cards")
        for index in range(6):
            var expected: Texture2D = diagnostic if game.legendary_offers[index]["id"] == "no-cap" else null
            if game.presentation.card_parts[index]["image"].texture != expected: failures.append("Legendary identity uses the same category-aware lookup")
    var after := JSON.stringify([game.rng.state,game.weapons,game.passives,game.hp,game.run_time])
    if before != after or original_passives != game.PASSIVES or game.PASSIVES.size() != 23:
        failures.append("Icon refresh cannot change simulation, RNG or passive scope")
    game.queue_free()
    await process_frame
    if failures.is_empty(): print("PASS: Approval registry, cached identity, fallback, live card/build resize and unchanged simulation"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
