extends SceneTree
const Registry = preload("res://scripts/approved_icon_registry.gd")
var failures: Array[String] = []
func _initialize() -> void: call_deferred("verify")
func verify() -> void:
    var registry := Registry.new()
    var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(Registry.MANIFEST))
    if manifest["icons"].size() != 37: failures.append("Creator batch has exactly 37 approved mappings")
    for row: Dictionary in manifest["icons"]:
        var texture: Texture2D = registry.texture(row["category"],row["id"])
        if texture == null:
            failures.append("Approved mapping missing: " + row["id"])
            continue
        if texture != registry.texture(row["category"],row["id"]): failures.append("Repeated lookup reuses texture")
        if texture.get_size() != Vector2(256,256): failures.append("Runtime master preserves 256px dimensions")
        # Checkout-only comparison: PCK textures are remapped imports, not raw source PNGs.
        var expected := Image.new()
        expected.load_png_from_buffer(FileAccess.get_file_as_bytes(row["resource_path"]))
        var actual := texture.get_image()
        expected.convert(Image.FORMAT_RGBA8)
        expected.fix_alpha_edges() # Match Godot lossless import; original PNG bytes stay immutable.
        actual.convert(Image.FORMAT_RGBA8)
        if expected.get_data() != actual.get_data(): failures.append("Imported texture pixels differ: " + row["id"])
        var wrong := "passive" if row["category"] == "weapon" else "weapon"
        if registry.texture(wrong,row["id"]) != null: failures.append("No cross-category substitution")
        if row["id"] == "touch-grass" and (row["artwork_version"] != "clean-cut-v2" or row["source_sha256"] != "3b8635df874e611debfffcae0b1d409da7a97708a9d710bd69588fb298102eca"):
            failures.append("Touch Grass uses exact approved raster v2 only")
    var game = load("res://scenes/main.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    for id in ["get-ratiod","ego-check","uno-reverse","brainrot-rain","take-l"]:
        if game.PASSIVES.has(id) or registry.texture("passive",id) == null: failures.append("Future art is mapped but remains unplayable")
    for starter in range(3):
        game.start_run(starter)
        game._gain_xp(100)
        game._open_choice()
        var before := JSON.stringify([game.rng.state,game.hp,game.run_time,game.weapons,game.passives,game.profile])
        game.presentation.refresh()
        for index in range(game.selection.size()):
            var item: Dictionary = game.selection[index]
            var category := "weapon" if game.WEAPONS.has(item["id"]) else "passive"
            var parts: Dictionary = game.presentation.card_parts[index]
            if parts["image"].texture != registry.texture(category,item["id"]) or not parts["image"].visible or parts["icon"].visible:
                failures.append("Legal live offers use approved texture identity")
            if parts["name"].text.is_empty(): failures.append("Names remain available for compact recognition")
        if before != JSON.stringify([game.rng.state,game.hp,game.run_time,game.weapons,game.passives,game.profile]): failures.append("Icon refresh preserves simulation/RNG/save")
    # Presentation-only per-item fixtures supplement the real offer-generation checks above.
    # They do not authorize future items or fabricate a normal run.
    for id in game.WEAPONS.keys() + game.PASSIVES:
        var category := "weapon" if game.WEAPONS.has(id) else "passive"
        var rarity: String = "common" if category == "weapon" else game.SoloOfferRulesScript.PASSIVE_DATA[id]["rarity"]
        var card := {"id":id,"rarity":rarity,"level":1,"type":category}
        game.mode = "choice"
        game.selection.assign([card])
        var before := JSON.stringify([game.rng.state,game.hp,game.run_time,game.weapons,game.passives,game.profile])
        game.presentation.refresh()
        if game.presentation.card_parts[0]["image"].texture != registry.texture(category,id): failures.append("Every playable ID binds the exact card artwork")
        if game.presentation.card_parts[0]["name"].text != game.presentation.catalog[id]["name"]: failures.append("Every playable ID preserves its actual name")
        if before != JSON.stringify([game.rng.state,game.hp,game.run_time,game.weapons,game.passives,game.profile]): failures.append("Per-ID art fixture does not advance simulation")
    game.start_run(0)
    game.passives.clear()
    for id in ["main-character","terminally-online","built-different","thick-skin","caught-4k"]:
        game.passives.append({"id":id,"rarity":"common","level":1})
    root.size = Vector2i(390,844)
    game.presentation._window_changed(true)
    game.mode = "playing"
    game.presentation.refresh()
    var hud_point := Vector2(30,game.presentation.view.y-(138 if game.presentation.view.x < 1000 else 62)+10)
    if not game.presentation.hud_item_caption(hud_point).contains("No Cap / WEAPON / COMMON / LV 1"): failures.append("Compact HUD exposes full actual name/category/rarity/level without stealing input")
    game.presentation.body_scroll.scroll_vertical = 1000
    game.presentation.open_build()
    await process_frame
    await process_frame
    if game.presentation.body_scroll.scroll_vertical != 0: failures.append("Opening build resets stale scroll so item names start in view")
    for slot: Dictionary in game.presentation.equipment_slots:
        if not slot["image"].visible: continue
        for key in ["label","meta"]:
            var label: Label = slot[key]
            if label.get_line_count() > label.get_visible_line_count(): failures.append("Compact build names and rarity/level cannot clip")
    game.queue_free()
    await process_frame
    if failures.is_empty(): print("PASS: All 37 approved PNG pixel identities, Touch Grass v2, legal offers, future-only scope and unchanged simulation"); quit(0)
    else:
        for failure in failures: push_error(failure)
        quit(1)
