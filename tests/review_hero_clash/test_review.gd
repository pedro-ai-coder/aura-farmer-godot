extends SceneTree
var failures := 0
func check(ok: bool, message: String) -> void:
    if not ok:
        failures += 1
        push_error(message)
func _initialize() -> void: call_deferred("run")
func run() -> void:
    var game = load("res://tests/review_hero_clash/review.tscn").instantiate()
    root.add_child(game)
    game.set_process(false)
    await process_frame
    var adapter = game.review_adapter
    for candidate in ["a","b","c"]:
        check(adapter.logo.treatment() in ["clash_bold","clash_circuit","clash_hybrid"],"All review candidates have explicit treatment identity")
        if candidate == "c":
            check(adapter.typography.FACES["c"][0] == adapter.typography.FACES["a"][0],"Hybrid uses Archivo Black display from candidate A")
            check(adapter.typography.FACES["c"][1] == adapter.typography.FACES["a"][1],"Hybrid uses Archivo UI from candidate A")
            check(adapter.typography.FACES["c"][0] != adapter.typography.FACES["b"][0],"Hybrid does not replace Bold display with Oxanium")
        adapter.typography.candidate = candidate
        adapter.typography.cache.clear()
        for role in adapter.typography.TOKENS:
            var face: FontVariation = adapter.typography.font(role)
            check(face.variation_embolden == 0,"Synthetic bold is prohibited")
            check(face.variation_transform == Transform2D.IDENTITY,"Synthetic distortion is prohibited")
            check(face.has_char(0xE7) and face.has_char(0xE3),"Portuguese glyph coverage")
        var face: FontVariation = adapter.typography.font("numeric_emphasis")
        var ts := TextServerManager.get_primary_interface()
        var coordinates := ts.font_get_variation_coordinates(face.get_rids()[0])
        check(int(coordinates.get(ts.name_to_tag("wght"),0)) == 700,"Runtime weight axis must resolve to 700")
        for dimensions in [Vector2i(1920,1080),Vector2i(1600,900),Vector2i(1280,720),Vector2i(915,412),Vector2i(844,390),Vector2i(390,844)]:
            root.size = dimensions
            game.start_run(0)
            game.aura = 100
            game._show_ui();game._update_text()
            await process_frame
            await process_frame
            adapter.last_key = "";adapter.refresh()
            check(game.flex_button.size == Vector2(128,128),"Circular Flex hit target")
            check(not game.flex_button.get_signal_connection_list("pressed").is_empty(),"Original Flex action connected")
            check(game.clean_cut_skin.flex_status.text == "READY","Ready fixture")
            check(not game.clean_cut_skin.wordmark.visible,"Approved wordmark hidden only in review")
            if candidate == "c":
                check(adapter.logo.treatment() == "clash_hybrid","Hybrid logo graphic treatment is selected")
                check(adapter.logo.size.x > 0.0 and adapter.logo.size.y >= 140.0,"Hybrid title has a significant review layout footprint")
                check(adapter.logo.visible == (game.mode == "menu"),"Hybrid logo never covers gameplay")
    game.queue_free()
    await process_frame
    print("Hero Clash review checks: ",failures," failures")
    quit(1 if failures else 0)
