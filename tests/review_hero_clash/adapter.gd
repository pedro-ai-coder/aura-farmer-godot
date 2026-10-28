extends Node
## Runs after the real skin; no reparenting or replacement of signal-bound game controls.
const Type = preload("typography.gd")
const Logo = preload("logo.gd")
var game
var typography = Type.new()
var logo: Control
var last_key := ""

func install(run, candidate: String) -> void:
    game = run
    typography.candidate = candidate
    process_priority = 100
    logo = Logo.new()
    logo.typography = typography
    logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
    game.clean_cut_skin.add_child(logo)

func _process(_delta: float) -> void:
    refresh()

func refresh() -> void:
    var skin = game.clean_cut_skin
    var key: String = str([skin.layout_count,typography.candidate])
    if key == last_key: return
    last_key = key
    var compact: bool = skin.view.x < 700 or skin.view.y < 550
    apply_tree(skin,compact)
    typography.apply(skin.hero_name,"hero_name",compact)
    typography.apply(skin.flex_status,"ability_status",compact)
    typography.apply(skin.heading,"display_xl" if game.mode in ["won","lost"] else "screen_heading",compact)
    for parts in skin.hero_parts: typography.apply(parts["name"],"hero_name",compact)
    for parts in skin.offer_parts:
        typography.apply(parts["category"],"rarity_label",compact)
        typography.apply(parts["state"],"ability_status",compact)
    typography.apply(skin.auxiliary.result_hero,"hero_name",compact)
    refine_layout(skin)
    fit_tree(skin)
    # Review the A/B/C candidates at the same live menu brand footprint.
    logo.position = skin.candidate_brand.position
    logo.size = skin.candidate_brand.size
    if game.mode == "menu" and typography.candidate == "c":
        # Correct the under-emphasized A logo. The hero still owns the right
        # side of the poster and interactive menu buttons retain their bounds.
        var compact_menu: bool = skin.view.x < 700.0 or skin.view.y < 550.0
        var width_ratio: float = 0.90 if skin.view.x < 700.0 else 0.47
        var logo_width: float = minf(skin.view.x-50.0,skin.view.x*width_ratio)
        var logo_height: float = 155.0 if compact_menu else 170.0
        logo.position = Vector2(28,22)
        logo.size = Vector2(logo_width,logo_height)
        skin.home_caption.position.y = 191.0 if compact_menu else 208.0
    logo.visible = game.mode == "menu"
    skin.wordmark.hide()
    skin.candidate_brand.hide()
    logo.queue_redraw()

func apply_tree(node: Node, compact: bool) -> void:
    if node is Label or node is Button or node is TextEdit or node is LineEdit:
        typography.apply(node,str(node.get_meta("typography_role","button_label" if node is Button else "body_text")),compact)
    for child in node.get_children(): apply_tree(child,compact)

func fit_tree(node: Node) -> void:
    if (node is Label or node is Button) and node.is_visible_in_tree() and not node.text.is_empty():
        var pixels: int = node.get_theme_font_size("font_size")
        var face: Font = node.get_theme_font("font")
        var available: float = node.size.x - (24 if node is Button else 0)
        if node is Button or node.autowrap_mode == TextServer.AUTOWRAP_OFF:
            var value: String = node.text.to_upper() if node is Label and node.uppercase else node.text
            while pixels > 16 and face.get_multiline_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,pixels).x > available:
                pixels -= 1
            node.add_theme_font_size_override("font_size",pixels)
    for child in node.get_children(): fit_tree(child)

func refine_layout(skin) -> void:
    if game.mode == "menu":
        skin.home_caption.add_theme_font_size_override("font_size",22 if skin.view.x < 700 else 26)
        if skin.view.x < 700:
            var backing := StyleBoxFlat.new()
            backing.bg_color = Color(0.07,0.13,0.20,0.94)
            backing.content_margin_left = 10
            backing.content_margin_right = 10
            backing.content_margin_top = 8
            backing.content_margin_bottom = 8
            skin.home_caption.add_theme_stylebox_override("normal",backing)
        else: skin.home_caption.remove_theme_stylebox_override("normal")
    skin.hero_name.add_theme_font_size_override("font_size",24)
    for parts in skin.equipment:
        var label: Label = parts["name"]
        var full: String = label.tooltip_text
        label.text = {"Keyboard Warrior":"Keyboard", "Personal Space":"Personal\nSpace", "Main Character Energy":"Main\nChar.", "Terminally Online":"Term.\nOnline", "Built Different":"Built\nDifferent", "Absolute Cinema":"Absolute\nCinema"}.get(full,label.text)
        label.add_theme_font_size_override("font_size",16)
        label.add_theme_constant_override("line_spacing",0)
        label.autowrap_mode = TextServer.AUTOWRAP_OFF
        label.position.y = parts["frame"].position.y+55
        label.size.y = 40
    if game.mode == "choice" and skin.view.y <= 550:
        var height: float = skin.view.y-196
        for i in range(3):
            var parts: Dictionary = skin.offer_parts[i]
            var button: Button = game.offer_buttons[i]
            button.size.y = height
            parts["icon"].position.y = 58
            parts["name"].position.y = 52
            parts["name"].size.y = 66
            parts["meta"].position.y = 122
            parts["body"].position.y = 156
            parts["body"].size.y = 66
            parts["comparison"].position.y = height-84
            parts["comparison"].size.y = 52
            parts["state"].position.y = height-28
        skin.offers_content.custom_minimum_size.y = height
        skin.offers_content.size.y = height
    if game.mode == "legendary":
        for i in range(skin.offer_parts.size()):
            var parts: Dictionary = skin.offer_parts[i]
            var body: Label = parts["body"]
            body.position.y = 130
            body.size.y = game.offer_buttons[i].size.y-166
            body.add_theme_font_size_override("font_size",17)
            body.add_theme_constant_override("line_spacing",1)
            body.max_lines_visible = -1
            body.text_overrun_behavior = TextServer.OVERRUN_NO_TRIMMING
    if game.mode != "playing": return
    # Production now owns the actual circular Flex dial. The font review may
    # change lettering, but must never replace its geometry or state component.
    skin.aura_arc.show()
    skin.aura_arc.show_state(game.aura/100.0,"ready" if game.aura>=100.0 else "charging")
