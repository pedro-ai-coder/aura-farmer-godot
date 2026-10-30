extends RefCounted
## Development-only measurements from live Controls after layout, never used by gameplay.
static func rect_data(r: Rect2) -> Array:return [r.position.x,r.position.y,r.size.x,r.size.y]
static func scan(node: Node, viewport: Viewport, rows: Array) -> void:
    if node is Control and node.is_visible_in_tree():
        var control: Control=node
        var logical: Rect2=control.get_global_rect()
        var screen: Rect2=viewport.get_final_transform()*logical
        var clip:=Rect2(Vector2.ZERO,Vector2(viewport.size))
        var ancestor: Node=control.get_parent()
        while ancestor!=null:
            if ancestor is Control and ancestor.clip_contents:clip=clip.intersection(viewport.get_final_transform()*ancestor.get_global_rect())
            ancestor=ancestor.get_parent()
        var row: Dictionary={"path":str(control.get_path()),"type":control.get_class(),"logical":rect_data(logical),"screen":rect_data(screen),"clip":rect_data(clip),"visible":true,"parent":str(control.get_parent().get_path()),"interactive":control is BaseButton,"mouse_filter":control.mouse_filter}
        if control is Label or control is Button:
            row["text"]=control.text
            row["font_logical"]=control.get_theme_font_size("font_size")
            row["font_physical"]=row["font_logical"]*viewport.get_final_transform().get_scale().y
            row["minimum"]=str(control.get_minimum_size())
        rows.append(row)
    for child in node.get_children():scan(child,viewport,rows)
static func report(game) -> Dictionary:
    var rows: Array=[];scan(game,get_viewport_for(game),rows)
    var skin=game.clean_cut_skin
    var issues: Array=[];var regions: Dictionary={}
    if game.mode=="playing":
        regions={"health":skin.player_plate.get_global_rect().merge(skin.shield_track.get_global_rect()),"wave":skin.wave_frame.get_global_rect(),"pause":game.pause_button.get_global_rect(),"xp":skin.xp_frame.get_global_rect().merge(skin.xp.get_global_rect()),"flex":game.flex_button.get_global_rect(),"flex_caption":skin.flex_caption.get_global_rect()}
        if skin.boss_plate.visible:regions["boss"]=skin.boss_plate.get_global_rect()
        # The boss phase label intentionally belongs inside the live boss module.
        if not skin.warning.text.is_empty() and not skin.boss_plate.visible:regions["warning"]=skin.warning.get_global_rect()
        if game.legendary_button.visible:regions["legendary"]=game.legendary_button.get_global_rect()
        var keys:=regions.keys()
        for i in range(keys.size()):
            for j in range(i+1,keys.size()):
                if regions[keys[i]].intersects(regions[keys[j]]):issues.append({"kind":"reserved_region_overlap","a":keys[i],"b":keys[j],"intersection":rect_data(regions[keys[i]].intersection(regions[keys[j]]))})
    if game.mode in ["choice","legendary","replace"]:
        for i in range(game.offer_buttons.size()):
            if not game.offer_buttons[i].visible:continue
            var parts: Dictionary=skin.offer_parts[i]
            var names: Array=["name","body","comparison","meta","state"]
            for a in range(names.size()):
                var first: Label=parts[names[a]]
                if not first.visible or first.text.is_empty():continue
                for b in range(a+1,names.size()):
                    var second: Label=parts[names[b]]
                    if second.visible and not second.text.is_empty() and first.get_rect().intersects(second.get_rect()):issues.append({"kind":"card_text_overlap","card":i,"a":names[a],"b":names[b]})
    if game.mode=="heroes":
        for i in range(3):
            var button: Button=game.menu_buttons[i]
            if skin.hero_parts[i]["flex"].get_rect().intersects(skin.hero_parts[i]["help"].get_rect()):issues.append({"kind":"hero_text_overlap","hero":i})
            for key in ["name","role","starter","flex","help"]:
                if not Rect2(Vector2.ZERO,button.size).encloses(skin.hero_parts[i][key].get_rect()):issues.append({"kind":"hero_text_outside","hero":i,"label":key})
    if game.mode=="build":
        for i in range(game.presentation.equipment_slots.size()):
            var slot: Dictionary=game.presentation.equipment_slots[i]
            if slot["label"].get_rect().intersects(slot["meta"].get_rect()):issues.append({"kind":"equipment_text_overlap","slot":i})
            if not Rect2(Vector2.ZERO,slot["panel"].size).encloses(slot["label"].get_rect()):issues.append({"kind":"equipment_text_outside","slot":i})
    var buttons: Array=[]
    for row in rows:
        if row["interactive"]:
            var r: Array=row["screen"];var c: Array=row["clip"]
            var effective:=Rect2(r[0],r[1],r[2],r[3]).intersection(Rect2(c[0],c[1],c[2],c[3]))
            if effective.has_area():buttons.append({"path":row["path"],"rect":effective})
    for i in range(buttons.size()):
        for j in range(i+1,buttons.size()):
            if buttons[i]["rect"].intersects(buttons[j]["rect"]):issues.append({"kind":"interactive_overlap","a":buttons[i]["path"],"b":buttons[j]["path"]})
    # Deliberate artwork layers (fill/track, label/face, icon/plate, selection
    # frame/card, rarity badge/header) are excluded from peer collision checks.
    return {"mode":game.mode,"viewport":str(game.get_viewport().size),"controls":rows,"issues":issues,"allowlist":["fill inside track","label on button face","icon inside plate","selection frame on card","rarity badge on card"]}
static func get_viewport_for(game) -> Viewport:return game.get_viewport()
